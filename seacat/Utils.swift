//
//  Utils.swift
//  SeaCat
//
//  Created by Ales Teska on 12.1.19.
//  Copyright © 2019 TeskaLabs. All rights reserved.
//

import Foundation
import CommonCrypto

struct OSStatusError: Error {
    
    let message: String
    let osStatus: OSStatus?
    let link: String
    
    init(message: String, osStatus: OSStatus?) {
        
        self.message = message
        self.osStatus = osStatus
        
        if let code = osStatus {
            
            link = "https://www.osstatus.com/search/results?platform=all&framework=Security&search=\(code)"
        }
        else {
            
            link = ""
        }
    }
}

func SeaCatSHA256(data: Data) -> Data {
    var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
    let _ = data.withUnsafeBytes { (ptr:UnsafeRawBufferPointer) -> UnsafeMutablePointer<UInt8>? in
        CC_SHA256(ptr.baseAddress, CC_LONG(ptr.count), &hash)
    }
    return Data(hash)
}

// This is platform-agnostic version of the SecCertificateCopyPublicKey() function
func SeaCatCertificateCopyPublicKey(certificate:SecCertificate) -> SecKey? {
    var public_key: SecKey?
    if #available(OSX 10.14, *), #available(iOS 10.3, *) {
        public_key = SecCertificateCopyKey(certificate)
    } else {
        #if os(OSX)
        let status = SecCertificateCopyPublicKey(certificate, &public_key)
        guard status == errSecSuccess else { return nil }
        #else
        public_key = SecCertificateCopyPublicKey(certificate)
        if public_key == nil { return nil }
        #endif
    }
    return public_key
}

// Common identity conversion functions

func SeaCatIdentity(public_key: SecKey) -> String? {
    var error: Unmanaged<CFError>?

    // For an elliptic curve public key, the format follows the ANSI X9.63 standard using a byte string of 04 || X || Y.
    let public_key_encoded = SecKeyCopyExternalRepresentation(public_key, &error)! as Data
    var hash = [UInt8](repeating: 0,  count: Int(CC_SHA384_DIGEST_LENGTH))
    public_key_encoded.withUnsafeBytes {
        _ = CC_SHA384($0, CC_LONG(public_key_encoded.count), &hash)
        
    }
    let d = Data(hash)
    let s = d.withUnsafeBytes {
        base32encode(UnsafeRawPointer($0), d.count)
    }
    
    return String(s[String.Index(encodedOffset: 0)..<String.Index(encodedOffset: 16)])
}

func SeaCatIdentity(private_key: SecKey) -> String? {
    guard let public_key = SecKeyCopyPublicKey(private_key) else { return nil }
    return SeaCatIdentity(public_key:public_key)
}

func SeaCatIdentity(certificate: SecCertificate) -> String? {
    guard let public_key = SeaCatCertificateCopyPublicKey(certificate: certificate) else { return nil }
    return SeaCatIdentity(public_key:public_key)
}

func SeaCatValidate(certificate:SecCertificate, identity:String) -> Bool {
    
    // Check that the identity of a certificate matched
    if SeaCatIdentity(certificate: certificate) != identity {
        return false;
    }

    //TODO: Verify the peer certificate (for validity and that is issued by a trusted CA)
    return true
}
