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
    
    public let identity: Identity = Identity()
    
    public init(apiURL: String, controller: Controller? = nil) {
        self.controller = controller ?? Controller()
        self.apiURL = URL(string: apiURL) ?? URL(string: "http://incorrect.url/")!
        
        identity.postInit(seacat:self)
    }

    
}
