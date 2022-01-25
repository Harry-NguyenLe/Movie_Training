//
//  RegisterViewController.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/3/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var btnMale: DLRadioButton!
    @IBOutlet weak var btnFemale: DLRadioButton!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var btnRule1: UIButton!
    @IBOutlet weak var btnRule2: UIButton!
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var txtBirthday: UITextField!
    
    @IBOutlet weak var lblNameError: UILabel!
    @IBOutlet weak var lblEmailError: UILabel!
    @IBOutlet weak var lblPasswordError: UILabel!
    @IBOutlet weak var lblConfirmPassError: UILabel!
    @IBOutlet weak var lblBirthDay: UILabel!
    
    let datePicker = UIDatePicker()
    var gender = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.hidesKeyboard()
        btnRegister.layer.cornerRadius = 5
        btnRule1.underline()
        btnRule2.underline()
        showDatePicker()
    }
    
    func showDatePicker() {
        self.datePicker.datePickerMode = .date
        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.calendar = calendar
        
        components.year = -9
        components.month = 7
        components.day = 15
        self.datePicker.maximumDate = Calendar.current.date(byAdding: components, to: Date())
        
        components.year = -120
        self.datePicker.minimumDate = Calendar.current.date(byAdding: components, to: Date())
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker(_ : )))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker(_ : )))
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        self.txtBirthday.inputAccessoryView = toolbar
        self.txtBirthday.inputView = self.datePicker
    }
    
    @objc func donedatePicker(_ sender: UIBarButtonItem) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.txtBirthday.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
    }
    
    @IBAction func diTapBtnRegister(_sender: UIButton) {
        if Reachability.isConnectedToNetwork() {
            if (checkValidate()) {
                callResgisterAPI()
            }
        } else {
            GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "alert", message: "Internet Connection not Available!")
        }
    }
    
    @IBAction func didTapBtnGender(_ sender: DLRadioButton) {
        self.gender = sender.currentTitle!
    }
    
    func checkValidate() -> Bool {
        guard txtName.text != "" else {
            lblNameError.isHidden = false
            return lblNameError.isHidden
        }
        guard txtEmail.text != "" else {
            lblEmailError.isHidden = false
            return lblEmailError.isHidden
        }
        guard txtPassword.text != "" else {
            lblPasswordError.isHidden = false
            return lblPasswordError.isHidden
        }
        guard txtConfirmPassword.text != "" else {
            lblConfirmPassError.isHidden = false
            lblConfirmPassError.text = "Bạn chưa xác nhận mật khẩu"
            return lblConfirmPassError.isHidden
        }
        guard txtPassword.text == txtConfirmPassword.text else {
            lblConfirmPassError.isHidden = false
            lblConfirmPassError.text = "Password và Confirm password phải giống nhau"
            return lblConfirmPassError.isHidden
        }
        guard txtBirthday.text != "" else {
            lblBirthDay.isHidden = false
            return lblBirthDay.isHidden
        }
        
        return true
    }
    
    func callResgisterAPI() {
        let email = txtEmail.text!
        let name = txtName.text!
        let password = txtPassword.text!
        let birthDay = txtBirthday.text!
        let sv = UIViewController.displaySpinner(onView: self.view)
        let params = "email=\(email)&password=\(password)&full_name=\(name)&gender=\(self.gender)&birthday=\(birthDay)"
        let headers: NSMutableDictionary = ["app_token": "dCuW7UQMbdvpcBDfzolAOSGFIcAec11a"]
        GlobalServices.httpService.sendHttpRequestForUploadingData("http://training-movie.bsp.vn:82/user/registry", param: params, header: headers, type: HttpRequestType.POST, HttpRequestContentType.UrlEncoded) { (isError, error, code, data) in
            GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: isError ? "Error" : "Success", message: isError ? error : "Đã đăng ký thành công", isDismiss: true)
            UIViewController.removeSpinner(spinner: sv)
        }
    }
    
    
    @IBAction func didTapBtnClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //    func callResgisterAPI() {
    //        let email = txtEmail.text!
    //        let name = txtName.text!
    //        let password = txtPassword.text!
    //        let sv = UIViewController.displaySpinner(onView: self.view)
    //        let url = URL(string: "http://training-movie.bsp.vn:82/user/registry")!
    //        var request = URLRequest(url: url)
    //        request.setValue("dCuW7UQMbdvpcBDfzolAOSGFIcAec11a", forHTTPHeaderField: "app_token")
    //        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    //        request.httpMethod = "POST"
    //        let postString = "email=\(email)&password=\(password)&full_name=\(name)"
    //        let data = postString.data(using: .utf8)
    //
    //        DispatchQueue.global(qos: .userInitiated).async {
    //            URLSession.shared.uploadTask(with: request, from: data, completionHandler: {(data, response, error) -> Void in
    //                if error != nil {
    //                    DispatchQueue.main.async {
    //                        let httpStatus = response as? HTTPURLResponse
    //                        if httpStatus == nil || httpStatus?.statusCode != 200 { // check for http errors
    //                        GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "Error!", message: "HTTP error code: \(String(describing: httpStatus?.statusCode))")
    //                            return
    //                        }
    //                        UIViewController.removeSpinner(spinner: sv)
    //                    }
    //                } else {
    //                    let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary
    //                    let error = jsonObj?!.value(forKey: "error") as! Bool
    //                    if error == false {
    //                        DispatchQueue.main.async
    //                            {                            GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "Success!", message: "Đã đăng ký thành công")
    //                                UIViewController.removeSpinner(spinner: sv)
    //                        }
    //                    } else {
    //                        DispatchQueue.main.async
    //                            {                            GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "Error!", message: jsonObj?!.value(forKey: "message") as! String)
    //                                UIViewController.removeSpinner(spinner: sv)
    //                        }
    //                    }
    //                }
    //            }).resume()
    //        }
    //    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
