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

    internal static var controller: Controller? = nil
    internal static var apiURL: URL? = nil
    public static let identity: Identity = Identity()
    
    private init() {}

    public class func initialize(apiURL: String, controller: Controller? = nil) {
        if (SeaCat.controller != nil) { return } // Already initialized
        SeaCat.controller = controller ?? Controller()
        self.apiURL = URL(string: apiURL)
        self.identity.initialize()
    }
    
}
