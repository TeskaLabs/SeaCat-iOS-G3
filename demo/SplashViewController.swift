//
//  ViewController.swift
//  demo
//
//  Created by Ales Teska on 26.2.20.
//  Copyright © 2020 TeskaLabs. All rights reserved.
//

import UIKit
import SeaCat

class SplashViewController: UIViewController {

    var timer: Timer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        // We wait till the SeaCat is ready and then we proceed to the application
        // SeaCat needs to do an initial enrolment to acquire the identity
        // This action can take a brief moment when the application is launched for a first time
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if (SeaCat.ready) { return }
            self.dismiss(animated: true, completion: nil)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
        timer = nil
    }
    
}
