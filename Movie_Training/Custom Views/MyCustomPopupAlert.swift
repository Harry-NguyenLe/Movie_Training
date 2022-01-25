//
//  MyCustomPopupAlert.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/5/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit

class MyCustomPopupAlert: UIAlertController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func displayMessage(onViewController: UIViewController, title: String, message: String, isDismiss: Bool = false) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
            if isDismiss {
                onViewController.dismiss(animated: true, completion: nil)
            }
        }
        alertView.addAction(OKAction)
        if let presenter = alertView.popoverPresentationController {
            presenter.sourceView = self.view
            presenter.sourceRect = self.view.bounds
        }
        onViewController.present(alertView, animated: true, completion:nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
