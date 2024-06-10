//
//  SeaCat.swift
//  SeaCat
//
//  Created by Ales Teska on 20.2.19.
//  Copyright © 2019-2020 TeskaLabs. All rights reserved.
//

import Foundation
import CommonCrypto

public class SeaCat {

    /// Initialization & configuration
    
    public init(apiURL: String, controller: Controller? = nil) {
        self.controller = controller ?? Controller()
        self.apiURL = URL(string: apiURL) ?? URL(string: "http://incorrect.url/")!
        self.identity = Identity()

        identity.postInit(seacat:self)
    }

    static private(set) public var instance: SeaCat?
    
    class public func configure(apiURL: String, controller: Controller? = nil) {
        instance = SeaCat(apiURL: apiURL, controller: controller)
    }
    
    
    /// SeaCat Identity
    
    public let identity: Identity
    
    static public var identity: Identity? {
        guard let seacat = instance else { return nil }
        return seacat.identity
    }

    
    /// SeaCat readiness
    
    public var ready: Bool {
        return self.identity.identity != nil
    }
    
    class public var ready: Bool {
        guard let seacat = instance else { return false }
        return seacat.ready
    }
    
    
    /// URL Session machinery
    
    public func createURLSession(configuration: URLSessionConfiguration = URLSessionConfiguration.default, delegateQueue queue: OperationQueue? = nil) -> URLSession {
        return URLSession(
            configuration: configuration,
            delegate: SeaCatURLSessionDelegate(seacat: self),
            delegateQueue: queue
        )

    }

    class public func createURLSession(configuration: URLSessionConfiguration = URLSessionConfiguration.default, delegateQueue queue: OperationQueue? = nil) -> URLSession? {
        guard let seacat = instance else { return nil }
        return seacat.createURLSession(configuration: configuration, delegateQueue: queue)
    }

    
    /// Private parts
    
    internal let controller: Controller
    internal let apiURL: URL

}
