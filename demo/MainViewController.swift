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

    let seacat = (UIApplication.shared.delegate as! AppDelegate).seacat
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (seacat.identity.identity == nil) {
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
            self.seacat.identity.revoke()
            self.seacat.identity.enroll()
            self.performSegue(withIdentifier: "SplashScreenSeque", sender: self)
        }))

        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in }))

        present(refreshAlert, animated: true, completion: nil)
    }

    private func update() {
        self.identityLabel.text = String(format: "Identity: %@", seacat.identity.identity ?? "-")
        if let certificate = seacat.identity.certificate {
            let summary = SecCertificateCopySubjectSummary(certificate)! as String
            self.certSummaryLabel.text = summary
        } else {
            self.certSummaryLabel.text = "-"
        }
    }
    
    @IBAction func onRequestClicked(_ sender: Any) {
        let url = URL(string: "http://www.stackoverflow.com")!

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8)!)
        }

        task.resume()
    }

}
