//
//  CertDelete.swift
//  SeaCat
//
//  Created by Ales Teska on 10.06.2024.
//  Copyright © 2024 TeskaLabs. All rights reserved.
//

import Foundation


func deleteCertificate(_ certificate: SecCertificate) {
    // Create a query to find the certificate in the keychain
    let query: [String: Any] = [
        kSecClass as String: kSecClassCertificate,
        kSecValueRef as String: certificate
    ]
    
    // Attempt to delete the certificate
    let status = SecItemDelete(query as CFDictionary)    
    if status != errSecSuccess {
        print("Failed to delete certificate:", certificate, "Error:", status)
    }
}
