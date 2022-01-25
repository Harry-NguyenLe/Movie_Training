//
//  LoginViewController.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/3/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit
import CoreData
import Firebase

protocol ReloadViewControllerDelegate : AnyObject {
    func loadData()
    func loadDataFromLocalDB()
    func loadUserLikedFilm()
    func clearAllAfterLogout()
}

class LoginViewController: UIViewController {

    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnResetPass: UIButton!
    @IBOutlet weak var btnFBLogin: UIButton!
    @IBOutlet weak var btnRegister: UIButton!
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    weak var delegate: ReloadViewControllerDelegate?
    
    static var userInfo: NSDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hidesKeyboard()
        btnLogin.layer.cornerRadius = 5
        btnResetPass.layer.cornerRadius = 5
        btnFBLogin.layer.cornerRadius = 5
        btnRegister.underline()
    }
    
    @IBAction func didTapBtnClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapBtnLogin(_ sender: UIButton) {
        if Reachability.isConnectedToNetwork() {
            guard txtUsername.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
                GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "Error!", message: "Please input your email")
                return
            }
            
            guard txtPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
                GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "Error!", message: "Please input your password")
                return
            }
            
            callLoginAPI(email: txtUsername.text!, password: txtPassword.text!)
        } else {
            let userName = self.txtUsername.text
            let password = self.txtPassword.text
//            let password = self.txtPassword.text?.toBase64()
            GlobalServices.localDatabse.fetchObjectWith(className: "UserData", predicate: NSPredicate(format: "email == %@ && password == %@", userName!, password!)) { (items) in
                if items == nil {
                    GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "Error", message: "Sai email hoặc mật khẩu")
                } else {
                    let user = items?.firstObject as! UserData
                    UserDefaults.standard.set(user.id, forKey: "uid")
                    UserDefaults.standard.set(user.full_name, forKey: "name")
                    UserDefaults.standard.set(user.profile_image, forKey: "profile_image")
                    self.delegate?.loadUserLikedFilm()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func didTapBtnResetPass(_ sender: UIButton) {
        let resetPassSV = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ResetPassView")
        self.present(resetPassSV, animated: true, completion: nil)
    }
    
    @IBAction func didTapBtnFBLogin(_ sender: UIButton) {
        if Reachability.isConnectedToNetwork() {
            GlobalServices.userService.loginFaceBook(self)
        } else {
            GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "alert", message: "Internet Connection not Available!")
        }
    }
    
    @IBAction func didTapBtnRegister(_ sender: UIButton) {
        let registerSV = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterView")
        self.present(registerSV, animated: true, completion: nil)
    }
    
    func callLoginAPI(email: String, password: String) {
        let sv = UIViewController.displaySpinner(onView: self.view)
        let url = "http://training-movie.bsp.vn:82/user/login"
        let postString = "email=\(email)&password=\(password)"
        
        GlobalServices.userService.checkLogin(self, url: url, params: postString) { isSuccess, error in
            
            guard isSuccess else {
                GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "Error", message: error)
                UIViewController.removeSpinner(spinner: sv)
                return
            }
            UIViewController.removeSpinner(spinner: sv)
        }
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

