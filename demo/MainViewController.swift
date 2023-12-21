//
//  MainViewController.swift
//  demo
//
//  Created by Ales Teska on 26.2.20.
//  Copyright © 2020 TeskaLabs. All rights reserved.
//

import UIKit
import SeaCat

class MainViewController: UIViewController {

    var timer: Timer? = nil

    @IBOutlet weak var identityLabel: UILabel!
    @IBOutlet weak var certSummaryLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (SeaCat.identity?.identity == nil) {
            performSegue(withIdentifier: "SplashScreenSeque", sender: self)
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in self.update() }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer?.invalidate()
        timer = nil
    }

    @IBAction func onRevokeClicked(_ sender: Any) {
        let refreshAlert = UIAlertController(
            title: "Revoke the identity",
            message: "The current identity will be lost.",
            preferredStyle: UIAlertController.Style.alert
        )

        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            SeaCat.identity?.revoke()
            SeaCat.identity?.enroll()
            self.performSegue(withIdentifier: "SplashScreenSeque", sender: self)
        }))

        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in }))

        present(refreshAlert, animated: true, completion: nil)
    }
    
    
    @IBAction func onRenewClicked(_ sender: Any) {
        SeaCat.identity?.enroll()
    }
    

    private func update() {
        self.identityLabel.text = String(format: "Identity: %@", SeaCat.identity?.identity ?? "-")
    }
    
    @IBAction func onRequestClicked(_ sender: Any) {
        let url = URL(string: "https://zscanner.seacat.io/medicalc/v3.1/departments")!
        
        guard let session = SeaCat.createURLSession() else { return }
        let task = session.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8)!)
        }

        task.resume()
    }

}
