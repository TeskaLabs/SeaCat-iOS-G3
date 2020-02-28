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
    let seacat = (UIApplication.shared.delegate as! AppDelegate).seacat
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if (self.seacat.identity.identity == nil) { return }
            self.dismiss(animated: true, completion: nil)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
        timer = nil
    }
    
}
