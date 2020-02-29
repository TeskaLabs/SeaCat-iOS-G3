//
//  Identity.swift
//  KeyoteKit
//
//  Created by Ales Teska on 20.2.19.
//  Copyright © 2019 TeskaLabs. All rights reserved.
//

import Foundation
import CommonCrypto

public class SeaCat {

    internal let controller: Controller
    internal let apiURL: URL
    public let identity: Identity
    
    
    /// Initialization & configuration
    
    public init(apiURL: String, controller: Controller? = nil) {
        self.controller = controller ?? Controller()
        self.apiURL = URL(string: apiURL) ?? URL(string: "http://incorrect.url/")!
        self.identity = Identity()

        identity.postInit(seacat:self)
    }

    static public var main: SeaCat?
    
    class public func configure(apiURL: String, controller: Controller? = nil) {
        main = SeaCat(apiURL: apiURL, controller: controller)
    }
    
    ///
    
    public var ready: Bool {
        return self.identity.identity != nil
    }
    
    class public var ready: Bool {
        guard let seacat = main else { return false }
        return seacat.ready
    }
    
    ///

    public func createURLSession(configuration: URLSessionConfiguration = URLSessionConfiguration.default, delegateQueue queue: OperationQueue? = nil) -> URLSession {
        return URLSession(
            configuration: configuration,
            delegate: SeaCatURLSessionDelegate(seacat: self),
            delegateQueue: queue
        )

    }

    class func createURLSession(configuration: URLSessionConfiguration = URLSessionConfiguration.default, delegateQueue queue: OperationQueue? = nil) -> URLSession? {
        guard let seacat = main else { return nil }
        return seacat.createURLSession(configuration: configuration, delegateQueue: queue)
    }

}
