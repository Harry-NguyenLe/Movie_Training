//
//  UserServices.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 6/6/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class UserServices: NSObject {
    
    func checkLogin(_ onViewController: UIViewController, url: String, params: String, completion: @escaping ( _ isSuccess: Bool, _ error: String) -> ()) {
        GlobalServices.httpService.sendHttpRequestForGetData(url, param: params, type: .POST, .UrlEncoded, handleComplete: { (isError, error, code, data) in
            
            guard !isError else {
                completion(false, error)
                return
            }
            
            let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary
            let userData = jsonObj??.value(forKey: "data") as? NSDictionary
//            guard userData != nil && email == userData?.value(forKey: "email") as? String else {
//                let message = jsonObj??.value(forKey: "message") as? String
//                //                        self.viewLoading.isHidden = true;
//
//                UIViewController.removeSpinner(spinner: sv)
//                return;
//            }
            
            let uid = userData?.value(forKey: "id") as! String
            UserDefaults.standard.set(uid, forKey: "uid")
            UserDefaults.standard.set(userData?.value(forKey: "full_name"), forKey: "name")
            let db = Firestore.firestore()
            let query = db.collection("userdata").whereField("id", isEqualTo: uid)
            query.getDocuments { (snapshot, error) in
                guard let snapshot = snapshot,
                    error == nil else {
                        completion(false, error!.localizedDescription)
                        return print("error: \(error!)")
                }
                guard !snapshot.isEmpty else {
                    completion(false, "results: 0")
                    return print("results: 0")
                }
                
                guard let user = snapshot.documents.first else {
                    completion(false, "Unknow Error")
                    return
                }
                
                if UserDefaults.standard.value(forKey: "device_token") != nil {
                    db.collection("userdata").document(uid).updateData(["device_token" : UserDefaults.standard.value(forKey: "device_token") as! String])
                } else {
                    InstanceID.instanceID().instanceID { (result, error) in
                        if let error = error {
                            completion(false, error.localizedDescription)
                            print("Error fetching remote instance ID: \(error)")
                        } else if let result = result {
                            UserDefaults.standard.setValue(result.token, forKey: "device_token")
                            db.collection("userdata").document(uid).updateData(["device_token" : result.token])
                        }
                    }
                    
                }
                
                UserDefaults.standard.set(user.get("profile_image") as! String, forKey: "profile_image")
                print(user.data()["profile_image"] as! String)
            }
            
            self.updateDataInfo(userData: userData!)
            if let listMovieView = onViewController as? LoginViewController {
                listMovieView.delegate?.loadUserLikedFilm()
            }
            onViewController.dismiss(animated: true)
            completion(true, "")
        })
    }
    
    func loginFaceBook(_ onViewController: UIViewController) {
        let fbLoginManager:LoginManager = LoginManager()
        fbLoginManager.loginBehavior = .browser
        fbLoginManager.logIn(permissions: ["email", "user_birthday", "user_gender"], from: onViewController, handler: { (result, error) -> () in
            if (error == nil) {
                let fbloginresult : LoginManagerLoginResult = result!
                if(fbloginresult.isCancelled) {
                    
                } else if(fbloginresult.grantedPermissions.count != 0) {
                    if(fbloginresult.grantedPermissions.contains("email")) {
                        self.returnUserData(onViewController)
                    }
                }
            }
        })

    }
    
    func returnUserData(_ onViewController: UIViewController) {
        if (AccessToken.current != nil) {
            GraphRequest(graphPath: "me", parameters: ["fields": "email, name, gender, birthday, picture.type(large)"]).start(completionHandler: {(connection, result, error) -> Void in
                if (error == nil) {
                    let faceDic = result as! NSDictionary
                    if let info = result as? [String : Any] {
                        let imageURL = ((info["picture"] as? [String: Any])?["data"] as? [String: Any])?["url"] as? String
                        UserDefaults.standard.set(imageURL, forKey: "fbImageURL")
                    }
                    
                    UserDefaults.standard.set(AccessToken.current?.userID, forKey: "uid")
                    UserDefaults.standard.set(faceDic.value(forKey: "name"), forKey: "name")
                    let userData: NSDictionary = ["id": "\(UserDefaults.standard.value(forKey: "uid") as! String)", "email":"\(faceDic.value(forKey: "email") as! String)", "full_name": "\(faceDic.value(forKey: "name") ?? "N/A")", "gender": "\(faceDic.value(forKey: "gender") ?? "N/A")", "birthday": "\(faceDic.value(forKey: "birthday") ?? "N/A")"]
                    self.updateDataInfo(userData: userData)
                    if let listMovieView = onViewController as? LoginViewController {
                        listMovieView.delegate?.loadUserLikedFilm()
                    }
                    onViewController.dismiss(animated: true)
                } else {
                    GlobalServices.myCustomPopupAlert.displayMessage(onViewController: onViewController, title: "Error", message: error!.localizedDescription)
                }
            })
        }
    }
    
    func updateDataInfo(userData: NSDictionary) {
        GlobalServices.localDatabse.fetchObjectWith(className: "UserData", predicate: NSPredicate(format: "id == %@", userData.value(forKey: "id") as! String)) { (items) in
            if items == nil {
                let userInfo = NSEntityDescription.insertNewObject(forEntityName: "UserData", into: GlobalServices.localDatabse.manageObjectContext) as! UserData
                userInfo.updataUserInfo(data: userData)
                GlobalServices.localDatabse.saveLocalDataBase()
            } else {
                //GlobalServices.localDatabse.saveLocalDataBase()
            }
        }
    }
}
