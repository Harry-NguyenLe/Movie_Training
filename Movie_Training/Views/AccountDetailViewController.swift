//
//  AccountDetailViewController.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/13/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit
import CoreData
import Firebase

protocol ReloadUserInfoDelegate: AnyObject {
    func getUserInfo()
}

class AccountDetailViewController: UIViewController, ReloadUserInfoDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet weak var lblBirthday: UILabel!
    
    @IBOutlet weak var btnChangePass: UIButton!
    @IBOutlet weak var btnChangeUserInfo : UIButton!
    @IBOutlet weak var btnChangeAvatar : UIButton!
    
    @IBOutlet weak var avatar: UIImageView!
    var imagePicker: UIImagePickerController!
    
    enum ImageSource {
        case photoLibrary
        case camera
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.btnChangePass.layer.cornerRadius = 5
        self.btnChangeUserInfo.layer.cornerRadius = 5
        if (AccessToken.current != nil) {
            btnChangePass.isEnabled = false
            btnChangePass.alpha = 0.4
            btnChangeUserInfo.isEnabled = false
            btnChangeUserInfo.alpha = 0.4
            btnChangeAvatar.isEnabled = false
            btnChangeAvatar.alpha = 0.4
        } else {
            btnChangePass.isEnabled = true
            btnChangeUserInfo.isEnabled = true
            btnChangeAvatar.isEnabled = true
        }
        loadImage()
        getUserInfo()
    }
    
    func loadImage() {
        self.avatar.layer.cornerRadius = self.avatar.frame.size.width / 2
        self.avatar.clipsToBounds = true
        self.avatar.layer.borderWidth = 3
        self.avatar.layer.borderColor = UIColor.white.cgColor
        let placeholderImage = UIImage(named: "bg.png")
        if UserDefaults.standard.value(forKey: "profile_image") != nil {
            let imagePath = UserDefaults.standard.value(forKey: "profile_image") as! String
            avatar.sd_setImage(with: URL(string: imagePath), placeholderImage: placeholderImage)
        } else if UserDefaults.standard.value(forKey: "fbImageURL") != nil {
            let imageUrl = URL(string: UserDefaults.standard.value(forKey: "fbImageURL") as! String)
            avatar.sd_setImage(with: imageUrl, placeholderImage: placeholderImage)
        }
    }
    
    func getUserInfo() {
        GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "", message: UserDefaults.standard.string(forKey: "uid")!)
        let sv = UIViewController.displaySpinner(onView: self.view)
        if (UserDefaults.standard.value(forKey: "uid") != nil) {
            GlobalServices.localDatabse.fetchObjectWith(className: "UserData", predicate: NSPredicate(format: "id == %@", UserDefaults.standard.string(forKey: "uid")!)) { (items) in
                if let userData = items?.firstObject as? UserData {
                    lblFullName.text = userData.full_name
                    lblEmail.text = userData.email
                    if (userData.gender == nil) {
                        lblGender.text = "N/A"
                    } else {
                        lblGender.text = userData.gender
                    }
                    lblBirthday.text = userData.birthday != nil ? userData.birthday : "N/A"
                }
            }
        }
        UIViewController.removeSpinner(spinner: sv)
    }
    
    @IBAction func didTapChangeAvatar(_ sender: UIButton) {
        let avatarView = UIAlertController(title: "", message: "Chọn ảnh đại diện", preferredStyle: .actionSheet)
        avatarView.addAction(UIAlertAction(title: "Chụp ảnh", style: .default, handler: {(action:UIAlertAction) in
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                return GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "Error", message: "Thiết bị không hổ trợ camera")
            }

            self.selectImageFrom(.camera)
        }))
        avatarView.addAction(UIAlertAction(title: "Chọn sẵn có", style: .default, handler: {(action:UIAlertAction) in
            self.selectImageFrom(.photoLibrary)
        }))
        avatarView.addAction(UIAlertAction(title: "Huỷ", style: .cancel, handler: nil))
        self.present(avatarView, animated: true, completion: nil)
    }
    
    func selectImageFrom(_ source: ImageSource){
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        switch source {
        case .camera:
            imagePicker.sourceType = .camera
        case .photoLibrary:
            imagePicker.sourceType = .photoLibrary
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: - Saving Image here
//    @IBAction func save(_ sender: AnyObject) {
//        guard let selectedImage = avatar.image else {
//            print("Image not found!")
//            return
//        }
//        UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
//    }
    
    @IBAction func didTapBtnChangeUserInfo(_ sender: UIButton) {
        let changeUserInfoSV = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChangeInfoView") as! ChangeBasicInfoViewController
        changeUserInfoSV.delegate = self
        self.present(changeUserInfoSV, animated: true)
    }
    
    @IBAction func didTapBtnChangePassword(_ sender: UIButton) {
        let changePassSV = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChangePassView")
        self.present(changePassSV, animated: true)
    }
    
    @IBAction func didTapBtnClose(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

extension AccountDetailViewController: UIImagePickerControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        imagePicker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        avatar.image = selectedImage
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            guard let selectedImage = avatar.image else {
                print("Image not found!")
                return
            }
            UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        uploadImageToFireStore(data: selectedImage.jpegData(compressionQuality: 0.5)! as NSData)
//        saveImg(selectedImage: selectedImage)
    }
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "Save error", message: error.localizedDescription)
        } else {
            GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "Saved!", message: "Your image has been saved to your photos.")
        }
    }
    
    func uploadImageToFireStore(data: NSData) {
        let uid = UserDefaults.standard.value(forKey: "uid") as! String
        let storage = Storage.storage()
        
        if let imagePath = UserDefaults.standard.value(forKey: "profile_image") {
            storage.reference(withPath: imagePath as! String).delete(completion: { (error) in
                if let err = error {
                    GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "Save error", message: err.localizedDescription)
                }
            })
        }
        
        let imageName = "\(uid)\(String(Date().timeIntervalSince1970).replacingOccurrences(of: ".", with: "")).jpg"
//        let imageName = "image_\(stringEncoding ?? "").jpg"
        let storageRef = storage.reference(withPath: "ProfileImages/\(imageName)")
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        storageRef.putData(data as Data, metadata: uploadMetaData , completion: {
            (metadata, error) -> Void in
                if let err = error {
                    GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "Save error", message: err.localizedDescription)
                } else {
                    storageRef.downloadURL { url, error in
                        guard let downloadURL = url else {
                            GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "Save error", message: error!.localizedDescription)
                            return
                        }
                        let db = Firestore.firestore()
                        let ref = db.collection("userdata").document(uid)
                        ref.updateData([
                            "profile_image": downloadURL.absoluteString
                        ]) { error in
                            if let err = error {
                                print("Error updating document: \(err.localizedDescription)")
                            } else {
                                UserDefaults.standard.set(downloadURL.absoluteString, forKey: "profile_image")
                                print("Document successfully updated")
                            }
                        }
                    }
                    print("Upload complete! Here's some metadata: \(String(describing: metadata?.bucket))")
                    
                }
            })
//        SDImageCache.shared().clearMemory()
//        SDImageCache.shared().clearDisk()
    }
    
    // save image to local
    func saveImg(selectedImage: UIImage) {
        var objCBool: ObjCBool = true
        let uid = UserDefaults.standard.value(forKey: "uid") as! String
        let imageName = "user_\(String(describing: uid)).png"
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true).first ?? ""
        let folderPath = "\(documentsDirectory)/Profile_Images/"
        let isExist = FileManager.default.fileExists(atPath: folderPath, isDirectory: &objCBool)
        
        //Checks if director exists, creates it if so.
        if !isExist {
            do {
                try FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "Error!", message: error.localizedDescription)
            }
        }
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageUrl =  documentDirectory.appendingPathComponent("Profile_Images/\(imageName)")
        
        //Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: imageUrl.path) {
            do {
                try FileManager.default.removeItem(atPath: imageUrl.path)
                print("Removed old image")
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }
            
        }
        
        if let data = selectedImage.jpegData(compressionQuality: 0.5) {
            do {
                try data.write(to: imageUrl)
                saveImgLinkToDB(uid: uid, imgLink: "Profile_Images/\(imageName)")
            } catch {
                GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "Error!", message: error.localizedDescription)
                print("Không thể lưu hình", error)
            }
        }
    }
    
    func saveImgLinkToDB(uid: String, imgLink: String) {
        GlobalServices.localDatabse.fetchObjectWith(className: "UserData", predicate: NSPredicate(format: "id == %@", uid)) { (items) in
            if items != nil {
                let object = items?.firstObject as! NSManagedObject
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                object.setValue(imgLink, forKey: "profile_image")
                object.setValue(formatter.string(from: date), forKey: "updated_at")
                GlobalServices.localDatabse.saveLocalDataBase()
                UserDefaults.standard.set(imgLink, forKey: "profile_image")
            }
        }
    }
}
