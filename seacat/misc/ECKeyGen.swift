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
    
    let privateKeyParameters : [String : AnyObject] = [
        kSecAttrIsPermanent as String : true as AnyObject,
        kSecAttrApplicationTag as String : privateTag as AnyObject,
        kSecAttrLabel as String: privateLabel as AnyObject,
    ]
    
    let publicKeyParameters : [String : AnyObject] = [
        kSecAttrIsPermanent as String : false as AnyObject,
        kSecAttrApplicationTag as String : publicTag as AnyObject,
        kSecAttrLabel as String: publicKeyLabel as AnyObject,
    ]
    
    let keyPairParameters : [String : AnyObject] = [
        kSecAttrKeySizeInBits as String : 256 as AnyObject,
        kSecAttrKeyType as String : kSecAttrKeyTypeEC,
        kSecPrivateKeyAttrs as String : privateKeyParameters as AnyObject,
        kSecPublicKeyAttrs as String : publicKeyParameters as AnyObject
    ]
    
    let status = SecKeyGeneratePair(keyPairParameters as CFDictionary, &publicKey, &privateKey)
    if status != noErr
    {
        print("Key generation error:", status)
        return nil
    }
    
    return (privateKey!, publicKey!)
}
