//
//  ResetPasswordViewController.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/3/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var lblNotice: UILabel!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btnSendLink: UIButton!
    @IBOutlet weak var btnOK: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hidesKeyboard()
        btnSendLink.layer.cornerRadius = 5
        btnOK.layer.cornerRadius = 20
    }
    
    @IBAction func btnSendLink(_ sender: UIButton) {
        if Reachability.isConnectedToNetwork() {
            if (txtEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "") {
                sender.alpha = 0.7
                callResetPassAPI()
            } else {
                txtEmail.text = ""
                GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "Error", message: "Nhập email")
            }
        } else {
            GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "alert", message: "Internet Connection not Available!")
        }
        
    }
    
    @IBAction func didTapBtnOK(_ sender: UIButton) {
        sender.alpha = 0.7
        lblNotice.isHidden = true
        sender.isHidden = true
    }
    
    func callResetPassAPI() {
        let email = txtEmail.text!
        let params: NSMutableDictionary = ["email": "\(email)"]
        let headers: NSMutableDictionary = ["app_token": "dCuW7UQMbdvpcBDfzolAOSGFIcAec11a"]
        let sv = UIViewController.displaySpinner(onView: self.view)
        GlobalServices.httpService.sendHttpRequestForUploadData("http://training-movie.bsp.vn:82/user/forgot-password", param: params, header: headers, type: HttpRequestType.POST, HttpRequestContentType.UrlEncoded) { (isError, error, code, data) in
            GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: isError ? "Error" : "Success", message: error)
            if (!isError) {
                self.btnOK.isHidden = false
                self.lblNotice.isHidden = false
            }
            UIViewController.removeSpinner(spinner: sv)
        }
    }
    
    @IBAction func didTapClose(_sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
