//
//  Controller.swift
//  seacat
//
//  Created by Ales Teska on 26.2.20.
//  Copyright © 2020 TeskaLabs. All rights reserved.
//

import Foundation

public class Controller {

    func onIntialEnrollmentRequested(seacat: SeaCat) {
        // You may decide to call seacat.identity.enroll() later, when you have more info
        seacat.identity.enroll()
    }

    func onReenrollmentRequested(seacat: SeaCat) {
        // You may decide to call seacat.identity.enroll() later, when you have more info
        seacat.identity.enroll()
    }
}
