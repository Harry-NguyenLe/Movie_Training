//
//  ChangePasswordViewController.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/13/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit
import CoreData

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var lblNewPass : UILabel!
    @IBOutlet weak var lblConfirmPass : UILabel!
    
    @IBOutlet weak var txtNewPassword : UITextField!
    @IBOutlet weak var txtConfirmNewPassword : UITextField!
    
    @IBOutlet weak var btnSavePass : UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.btnSavePass.layer.cornerRadius = 5
        self.hidesKeyboard()
    }
    
    @IBAction func didTapBtnSavePassword(_sender: UIButton) {
        if (checkValidate()) {
            let uid = UserDefaults.standard.value(forKey: "uid") as! String
            GlobalServices.localDatabse.fetchObjectWith(className: "UserData", predicate: NSPredicate(format: "id == %@", uid)) { (items) in
                if items != nil {
                    let object = items?.firstObject as! NSManagedObject
                    let date = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                    object.setValue(txtNewPassword.text, forKey: "password")
                    object.setValue(formatter.string(from: date), forKey: "updated_at")
                    GlobalServices.localDatabse.saveLocalDataBase()
                    GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "Success", message: "Mật khẩu đã được đổi", isDismiss: true)
                }
            }
        }
    }
    
    func checkValidate() -> Bool {
        guard txtNewPassword.text != "" else {
            lblNewPass.isHidden = false
            return false
        }
        guard txtConfirmNewPassword.text != "" else {
            lblNewPass.isHidden = true
            lblConfirmPass.isHidden = false
            return false
        }
        guard txtNewPassword.text == txtConfirmNewPassword.text else {
            lblNewPass.isHidden = true
            lblConfirmPass.text = "Password và Confirm password phải giống nhau"
            return false
        }
        
        return true
    }
    
    @IBAction func didTapBtnClose(_ sender: UIButton) {
        self.dismiss(animated: true)
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
