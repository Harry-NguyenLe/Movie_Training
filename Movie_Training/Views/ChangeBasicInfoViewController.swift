//
//  ChangeBasicInfoViewController.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/13/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit
import CoreData

class ChangeBasicInfoViewController: UIViewController {

    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblBirthDay: UILabel!
    
    @IBOutlet weak var txtBirthDay : UITextField!
    @IBOutlet weak var txtFullName : UITextField!
    
    @IBOutlet weak var btnSaveInfo : UIButton!
    @IBOutlet weak var btnMale : DLRadioButton!
    @IBOutlet weak var btnFemale: DLRadioButton!
    
    let datePicker = UIDatePicker()
    weak var delegate: ReloadUserInfoDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.hidesKeyboard()
        btnSaveInfo.layer.cornerRadius = 5
        loadUserInfo()
        showDatePicker()
        loadUserInfo()
    }
    
    func loadUserInfo() {
        let uid = UserDefaults.standard.value(forKey: "uid") as! String
        GlobalServices.localDatabse.fetchObjectWith(className: "UserData", predicate: NSPredicate(format: "id == %@", uid)) { (items) in
            if items != nil {
                let object = items?.firstObject as! UserData
                txtFullName.text = object.full_name
                txtBirthDay.text = object.birthday
                if (object.gender?.lowercased() == "male") {
                    btnMale.isSelected = true
                } else if (object.gender?.lowercased() == "female") {
                    btnFemale.isSelected = true
                }
            }
        }
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
        
        self.txtBirthDay.inputAccessoryView = toolbar
        self.txtBirthDay.inputView = self.datePicker
    }
    
    @objc func donedatePicker(_ sender: UIBarButtonItem) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.txtBirthDay.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
    }
    
    @IBAction func didTapBtnClose(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapBtnSaveInfo(_ sender: UIButton) {
        if checkValidate() {
            let uid = UserDefaults.standard.value(forKey: "uid") as! String
            GlobalServices.localDatabse.fetchObjectWith(className: "UserData", predicate: NSPredicate(format: "id == %@", uid)) { (items) in
                if items != nil {
                    let object = items?.firstObject as! NSManagedObject
                    let date = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                    object.setValue(txtFullName.text, forKey: "full_name")
                    object.setValue(txtBirthDay.text, forKey: "birthday")
                    if (btnMale.isSelected) {
                        object.setValue(btnMale.currentTitle?.lowercased(), forKey: "gender")
                    } else if (btnFemale.isSelected) {
                        object.setValue(btnFemale.currentTitle?.lowercased(), forKey: "gender")
                    }
                    object.setValue(formatter.string(from: date), forKey: "updated_at")
                    GlobalServices.localDatabse.saveLocalDataBase()
                    self.delegate?.getUserInfo()
                    GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "Success", message: "Thông tin đã được cập nhật", isDismiss: true)
                }
            }
        }
    }
    
    func checkValidate() -> Bool {
        guard txtFullName.text != "" else {
            lblFullName.isHidden = false
            return false
        }
        guard txtBirthDay.text != "" else {
            lblBirthDay.isHidden = false
            return false
        }
        
        return true
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
