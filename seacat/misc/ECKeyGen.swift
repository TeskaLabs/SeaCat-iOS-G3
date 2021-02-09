//
//  ECKeyGen.swift
//  SeaCat
//
//  Created by Ales Teska on 2.3.20.
//  Copyright © 2020 TeskaLabs. All rights reserved.
//

import Foundation

func generateECKeyPair(publicKeyTag: String, publicKeyLabel: String, privateKeyTag:String, privateLabel: String) -> (SecKey, SecKey)? {
    var publicKey: SecKey?
    var privateKey: SecKey?

    guard let publicTag = publicKeyTag.data(using: .utf8) else { return nil }
    guard let privateTag = privateKeyTag.data(using: .utf8) else { return nil }
    
    let privateKeyParameters : [String : Any] = [
        kSecAttrIsPermanent as String : true,
        kSecAttrApplicationTag as String : privateTag,
        kSecAttrLabel as String: privateLabel,
    ]
    
    let publicKeyParameters : [String : Any] = [
        kSecAttrIsPermanent as String : false,
        kSecAttrApplicationTag as String : publicTag,
        kSecAttrLabel as String: publicKeyLabel,
    ]
    
    let keyPairParameters : [String : Any] = [
        kSecAttrKeySizeInBits as String : 256,
        kSecAttrKeyType as String : kSecAttrKeyTypeEC,
        kSecPrivateKeyAttrs as String : privateKeyParameters,
        kSecPublicKeyAttrs as String : publicKeyParameters
    ]
    
    let status = SecKeyGeneratePair(keyPairParameters as CFDictionary, &publicKey, &privateKey)

    guard status == errSecSuccess else {
        print("Key generation error:", status)
        return nil
    }
    
    if (privateKey == nil) {
        print("Key generation error - private key missing")
        return nil
    }

    if (publicKey == nil) {
        print("Key generation error - private key missing")
        return nil
    }

    return (privateKey!, publicKey!)
}
