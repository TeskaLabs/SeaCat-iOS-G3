//
//  Controller.swift
//  seacat
//
//  Created by Ales Teska on 26.2.20.
//  Copyright © 2020 TeskaLabs. All rights reserved.
//

import Foundation

public class Controller {

    func onIntialEnrollmentRequested() {
        // You may decide to call seacat.identity.enroll() later, when you have more info
        SeaCat.identity.enroll()
    }

    func onReenrollmentRequested() {
        // You may decide to call seacat.identity.enroll() later, when you have more info
        SeaCat.identity.enroll()
    }
}
