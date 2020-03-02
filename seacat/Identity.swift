//
//  Identity.swift
//  SeaCat
//
//  Created by Ales Teska on 26.2.20.
//  Copyright © 2020 TeskaLabs. All rights reserved.
//

import Foundation
import CommonCrypto

public class Identity {
    
    static let privateTagString = "com.teskalabs.seacat.privateKey"
    static let privateKeyLabel = "SeaCat Identity Private Key"

    static let publicTagString = "com.teskalabs.seacat.publicKey"
    static let publicKeyLabel = "SeaCat Identity Public Key"

    weak private var seacat: SeaCat?
    
    internal func postInit(seacat: SeaCat) {
        
        self.seacat = seacat
        
        // Initialize the identity
        // The load has to happen in the synchronous way so that we indicate consistently if the identity is usable or nor
        if (load()) {
            let _ = verify()
        } else {
            DispatchQueue.global(qos: .background).async {
                self.renew()
            }
        }
    }
    
    
    func renew() {
        guard let seacat = seacat else { return }
        if (certificate == nil) {
           seacat.controller.onIntialEnrollmentRequested(seacat: seacat)
        } else {
            seacat.controller.onReenrollmentRequested(seacat: seacat)
        }
    }
    
    
    private func load() -> Bool {
        // Load an identity private key
        guard let privatekey = privateKey else { return false }

        guard let private_key_identity = SeaCatIdentity(private_key: privatekey) else {
            return false
        }

        // Scan the keychain and find an identity certificate
        let query: [String: Any] = [
            kSecClass as String: kSecClassCertificate,
            kSecReturnAttributes as String: kCFBooleanTrue as Any,
            kSecReturnRef as String: kCFBooleanTrue as Any,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]
        
        var result: AnyObject?
        let status = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        guard status == errSecSuccess else {
            return false
        }
        
        for item in (result as? Array<Dictionary<String, Any>>)! {
            let c = item["v_Ref"] as! SecCertificate
            let certificate_identity = SeaCatIdentity(certificate: c)
            if certificate_identity != private_key_identity {
                continue
            }
            
            //TODO: Other identity validations such as time validity
            self.certificate = c
            break
        }
        
        if self.certificate == nil {
            print("Identity certificate for \(private_key_identity) not found.")
            return false
        }

//        NotificationCenter.default.post(
//            name: Keyote.Notification.identitySet,
//            object: nil,
//            userInfo: [
//                "identity": self.identity as Any
//            ]
//        )
        
        return true
    }

    
    public func enroll() {
        // Get an existing identity keypair or generate a new one
        guard let keypair = generateECKeyPair(
            publicKeyTag: Identity.publicTagString,
            publicKeyLabel: Identity.publicKeyLabel,
            privateKeyTag: Identity.publicTagString,
            privateLabel: Identity.privateKeyLabel)
            else { return }
        guard let cr = buildCertificateRequest(privateKey: keypair.0, publicKey: keypair.1) else { return }
        enrollCertificateRequest(certificate_request: cr)
    }

    
    public func revoke() {
        var status:OSStatus

        let private_key = privateKey
        
        var p_identity: String?
        if (private_key != nil) {
            p_identity = SeaCatIdentity(private_key: private_key!)
        }

        self.certificate = nil
        
        // Remove the identity certificate
        if (p_identity != nil) {

            let query:[String: Any] = [
                kSecClass as String: kSecClassCertificate,
                kSecReturnAttributes as String: kCFBooleanTrue as Any,
                kSecReturnRef as String: kCFBooleanTrue as Any,
                kSecMatchLimit as String: kSecMatchLimitAll
            ]
            
            var hashes:[Data] = []
            
            var result: AnyObject?
            status = withUnsafeMutablePointer(to: &result) {
                SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
            }
            if status == errSecSuccess {
                for item in (result as? Array<Dictionary<String, Any>>)! {
                    let c = item["v_Ref"] as! SecCertificate
                    let c_identity = SeaCatIdentity(certificate: c)
                    if c_identity == p_identity {
                        hashes.append(item[kSecAttrPublicKeyHash as String] as! Data)
                    }
                }
            }
            
            for hash in hashes {
                repeat {
                    let query1: [String: Any] = [
                        kSecClass as String: kSecClassCertificate,
                        kSecAttrPublicKeyHash as String: hash,
                    ]
                    status = SecItemDelete(query1 as CFDictionary)
                } while (status == 0)
            }
        }
        
        // Remove an identity private key
        repeat {
            let privateTag = Identity.privateTagString.data(using: .utf8)!
            let query2: [String: Any] = [
                kSecClass as String: kSecClassKey,
                kSecAttrApplicationTag as String: privateTag as AnyObject,
            ]
            status = SecItemDelete(query2 as CFDictionary)
        } while (status == 0)
        
        // Remove an identity public key
        repeat {
            let publicTag = Identity.publicTagString.data(using: .utf8)!
            let query3: [String: Any] = [
                kSecClass as String: kSecClassKey,
                kSecAttrApplicationTag as String: publicTag as AnyObject,
            ]
            status = SecItemDelete(query3 as CFDictionary)
        } while (status == 0)

        //TODO: Send a revocation info to a SeaCat PKI
    }
    
    
    // Check validity of the identity certificate
    func verify() -> Bool {
        //TODO: This ...
        return true
    }
    
    
    private func buildCertificateRequest(privateKey: SecKey, publicKey: SecKey) -> Data? {
        var error: Unmanaged<CFError>?

        let public_key_encoded = SecKeyCopyExternalRepresentation(publicKey, &error)! as Data
        
        let created_at = Date()
        let valid_to = Calendar.current.date(byAdding: .minute, value: 5, to: created_at)! // CR is valid for 5 minutes
        
        let info = Bundle.main.infoDictionary!
        let appId = info[kCFBundleIdentifierKey as String] as! String
        
        // Build a request body that will be signed (to-be-signed)
        var tbsRequest = MiniASN1DER.SEQUENCE([
            MiniASN1DER.INTEGER(0x1902), // version
            MiniASN1DER.UTF8String(appId), // application
            MiniASN1DER.UTCTime(created_at), // createdAt
            MiniASN1DER.UTCTime(valid_to), // validTo
            MiniASN1DER.SEQUENCE([ // SubjectPublicKeyInfo
                MiniASN1DER.SEQUENCE([ // algorithm
                    MiniASN1DER.OBJECT_IDENTIFIER("1.2.840.10045.2.1"), // ecPublicKey (ANSI X9.62 public key type)
                    MiniASN1DER.OBJECT_IDENTIFIER("1.2.840.10045.3.1.7") // prime256v1 (ANSI X9.62 named elliptic curve)
                ]),
                MiniASN1DER.BIT_STRING(public_key_encoded), //subjectPublicKey
            ]),
            MiniASN1DER.SEQUENCE_OF([ // Parameters
            ])
        ])
        tbsRequest[0] = 0xA0
        
        let tbsRequestData = Data(tbsRequest)
        
        guard let cfSignature = SecKeyCreateSignature(
            privateKey,
            .ecdsaSignatureMessageX962SHA256,
            tbsRequestData as CFData,
            &error
        ) else {
            print("Certificate request signature error:", error ?? "")
            return nil
        }
        let signature = cfSignature as Data

        return Data(MiniASN1DER.SEQUENCE([
            tbsRequest,
            MiniASN1DER.SEQUENCE([
                MiniASN1DER.OBJECT_IDENTIFIER("1.2.840.10045.4.3.2") // ecdsa-with-SHA256
            ]),
            MiniASN1DER.OCTET_STRING(signature)
        ]))
    }
    
    
    private func enrollCertificateRequest(certificate_request: Data) {
        guard let seacat = seacat else { return }
        var request = URLRequest(url: seacat.apiURL.appendingPathComponent("/enroll"))
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
        request.httpBody = certificate_request
        
        //TODO: Introduce a certificate pinning (pre-loaded public keys of the keyote.teskalabs.com ... have a couple of them)
        URLSession.shared.dataTask(with: request) {
            data, response, error in
            if let error = error {
                print("Error when calling CA server: \(error)")
                return
            }
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode != 200 {
                print("Received incorrect response from CA server (enrollment):", statusCode)
                return
            }
            
            guard let data = data else {
                print("Received no data response from CA server (enrollment)")
                return
            }
            
            guard let certificate = SecCertificateCreateWithData(nil, data as CFData) else {
                print("Received invalid certificate from CA server (enrollment)")
                return
            }
            
            guard let privatekey = self.privateKey else {
                print("Invalid private key :-(")
                return
            }
            
            // Validate that certificate belongs to a private key
            guard let c_identity = SeaCatIdentity(certificate: certificate) else { return } // This is the certificate we received
            guard let p_identity = SeaCatIdentity(private_key: privatekey) else { return } // This is the private key we used to produce a request
            
            if c_identity != p_identity {
                print("The identity of my private key doesn't match with an identity of a certificate we received (enrollment): \(c_identity) != \(p_identity)")
                return
            }

            // Store the certificate in the system keychain
            let addquery: [String: Any] = [
                kSecClass as String: kSecClassCertificate,
                kSecValueRef as String: certificate,
                kSecAttrLabel as String: "Keyote Identity Certificate"
            ]
            let status = SecItemAdd(addquery as CFDictionary, nil)
            guard status == errSecSuccess else {
                print("Cannot store Keyote Identity Certificate in a keychain")
                return
            }

            if (!self.load()) {
                print("Cannot load a freshly received identity")
                return
            }

        }.resume()
    }
    

    /// Cryptographically calculated identity of the application instance
    ///
    
    public private(set) var certificate: SecCertificate?
    
    public var identity: String? {
        guard let certificate = self.certificate else { return nil }
        return SeaCatIdentity(certificate: certificate)
    }

    
    /// Return Apple SecIdentity, which is a combination of the certificate and the private key
    ///
    public var secIdentity: SecIdentity? {
#if os(OSX)
        // macOS version
        guard let certificate = self.certificate else { return nil }
        var identity: SecIdentity?
        let status = SecIdentityCreateWithCertificate(nil, certificate, &identity)
        guard status == errSecSuccess else { return nil }
#else
        // iOS version
        let privateTag = Identity.privateTagString.data(using: .utf8)!
        
        let getquery: [String: AnyObject] = [
            kSecClass as String: kSecClassIdentity,
            kSecAttrApplicationTag as String: privateTag as AnyObject,
            kSecReturnRef as String: true as AnyObject
        ]
        var item: CFTypeRef? = nil
        let status = SecItemCopyMatching(getquery as CFDictionary, &item)
        guard status == errSecSuccess else {
            print("Identity not found!")
            return nil
        }
        
        let identity = item as! SecIdentity
#endif
        return identity
    }

    
    var privateKey: SecKey? {
        let privateTag = Identity.privateTagString.data(using: .utf8)!
        let getquery: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: privateTag as AnyObject,
            kSecReturnRef as String: true
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(getquery as CFDictionary, &item)
        guard status == errSecSuccess else {
            return nil
        }
        return (item as! SecKey)
    }

}
