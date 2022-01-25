//
//  LeftSideViewController.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/10/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit
import Firebase

class LeftSideViewController: UIViewController {

    @IBOutlet weak var listMenuTableView: UITableView!
    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    var listMenu = [""]
    var listImage = [#imageLiteral(resourceName: "user-icon-32.png")]
    weak var delegate: ReloadViewControllerDelegate?
    private var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let imageView = UIImageView(image: UIImage(named: "bg@3x.png"))
        imageView.contentMode = .scaleToFill
        self.listMenuTableView.backgroundView = imageView
        self.listMenuTableView.dataSource = self
        self.listMenuTableView.delegate = self
        self.listMenuTableView.register(UINib(nibName: "LeftMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "LeftMenuTableViewCell")
        self.loadImage()
        if UserDefaults.standard.value(forKey: "uid") != nil {
            listMenu = ["Account", "Chat", "Logout"]
            listImage = [#imageLiteral(resourceName: "user-icon-32.png"), #imageLiteral(resourceName: "chat-icon-32.png"), #imageLiteral(resourceName: "door-out-icon-32.png")]
            lblName.text = UserDefaults.standard.value(forKey: "name") as? String
        } else {
            listMenu = ["Login"]
            listImage = [#imageLiteral(resourceName: "iconfinder_door_in_35977.png")]
        }
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
//            // ...
//        }
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        Auth.auth().removeStateDidChangeListener(handle!)
//    }
    
    
    
    func loadImage() {
        self.imageProfile.layer.cornerRadius = self.imageProfile.frame.size.width / 2
        self.imageProfile.clipsToBounds = true
        self.imageProfile.layer.borderWidth = 3
        self.imageProfile.layer.borderColor = UIColor.white.cgColor
        let placeholderImage = UIImage(named: "bg.png")
        if UserDefaults.standard.value(forKey: "profile_image") != nil {
            let imgPath = UserDefaults.standard.value(forKey: "profile_image") as! String
            self.imageProfile.sd_setImage(with: URL(string: imgPath), placeholderImage: placeholderImage) { (image, error, cacheType, storageRef) -> Void in
                if error != nil {
                    print(error?.localizedDescription as Any)
                } else {
                    
                }
            }
        } else if UserDefaults.standard.value(forKey: "fbImageURL") != nil {
            let imageUrl = URL(string: UserDefaults.standard.value(forKey: "fbImageURL") as! String)
            imageProfile.sd_setImage(with: imageUrl, placeholderImage: placeholderImage)
        }
    }
    
    func fbLogout() {
        let fbLoginManager:LoginManager = LoginManager()
        let deleteAllpermission = GraphRequest(graphPath: "me/permissions/", httpMethod: HTTPMethod(rawValue: "DELETE"))
        deleteAllpermission.start(completionHandler: {(connection, result, error)-> Void in
            if error == nil {
                fbLoginManager.logOut()
            } else {
                GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "Error", message: error!.localizedDescription)
            }
        })
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

extension LeftSideViewController:UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listMenu.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeftMenuTableViewCell") as! LeftMenuTableViewCell
        cell.lblIconTitle.text = self.listMenu[indexPath.row]
        cell.iconView.image = listImage[indexPath.row]
        
        if cell.lblIconTitle.text == "Chat" {
            let db = Firestore.firestore()
            let uid = UserDefaults.standard.value(forKey: "uid") as! String
            db.collection("userdata").document(uid).getDocument { querySnapshot, error in
                guard let querySnapshot = querySnapshot else {
                    print(error!.localizedDescription)
                    return
                }
                
                let message = querySnapshot.get("new_message") as! Int
                if message > 0 && message < 100 {
                    cell.newMsgView.isHidden = false
                    cell.lblNewMsg.text = "\(message)"
                } else if (message > 99) {
                    cell.newMsgView.isHidden = false
                    cell.lblNewMsg.text = "99+"
                } else {
                    cell.newMsgView.isHidden = true
                    cell.lblNewMsg.text = "0"
                }
            }
        }
    
        return cell
    }
}

extension LeftSideViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! LeftMenuTableViewCell
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let mainSV = self.mm_drawerController.centerViewController as! UINavigationController
        let movieList = mainSV.viewControllers.first as! MovieListTableViewController
        if (cell.lblIconTitle.text == "Login") {
            let loginSV = storyBoard.instantiateViewController(withIdentifier: "LoginSV") as! LoginViewController
            loginSV.delegate = movieList
            self.mm_drawerController.closeDrawer(animated: true, completion: nil)
            self.present(loginSV, animated: true, completion: nil)
        } else if (cell.lblIconTitle.text == "Account") {
            let accountSV = storyBoard.instantiateViewController(withIdentifier: "AccountView")
            self.present(accountSV, animated: true, completion: nil)
            self.mm_drawerController.closeDrawer(animated: true, completion: nil)
        } else if (cell.lblIconTitle.text == "Chat") {
            let channelSV = UIStoryboard.init(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "MainChannelView")
            self.present(channelSV, animated: true, completion: nil)
            self.mm_drawerController.closeDrawer(animated: true, completion: nil)
        } else if (cell.lblIconTitle.text == "Logout") {
            if AccessToken.current != nil {
                let fbLoginManager:LoginManager = LoginManager()
                fbLoginManager.logOut()
            }
            movieList.clearAllAfterLogout()
            self.mm_drawerController.closeDrawer(animated: true, completion: nil)
        }
    }
//
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.last == 9 {
//            GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "End Page", message: "Loading")
//        }
//    }
}


