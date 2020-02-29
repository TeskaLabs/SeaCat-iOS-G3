//
//  URLSessionDelegate.swift
//  SeaCat
//
//  Created by Ales Teska on 28.2.20.
//  Copyright © 2020 TeskaLabs. All rights reserved.
//

import Foundation

open class SeaCatURLSessionDelegate: NSObject, URLSessionDelegate {
    let seacat: SeaCat
    
    public init(seacat: SeaCat) {
        self.seacat = seacat
    }

    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        let authenticationMethod = challenge.protectionSpace.authenticationMethod
        
        if authenticationMethod == NSURLAuthenticationMethodClientCertificate {
            completionHandler(.useCredential, getClientCertificateURLCredential())

        } else if authenticationMethod == NSURLAuthenticationMethodServerTrust {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    
    func getClientCertificateURLCredential() -> URLCredential? {
        guard let identity = seacat.identity.secIdentity else { return nil }
        guard let certificate = seacat.identity.certificate else { return nil }
        return URLCredential(
            identity: identity,
            certificates: [certificate],
            persistence: URLCredential.Persistence.permanent
        )
    }
}
