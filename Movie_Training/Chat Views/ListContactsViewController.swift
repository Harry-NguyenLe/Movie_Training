//
//  ListContactsViewController.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/28/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit
import Firebase

class ListContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableContact : UITableView!
    
    var listChannel = NSMutableArray()
    let contacts = NSMutableArray()
    let listReceiver = NSMutableArray()
    let senderID = UserDefaults.standard.value(forKey: "uid") as! String
    var channelID = ""
    
    weak var delegateMoveToView : PushToViews?
    weak var delegateReloadView : ReloadChannelsViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableContact.dataSource = self
        self.tableContact.delegate = self
        self.tableContact.register(UINib(nibName: "ContactTableViewCell", bundle: nil), forCellReuseIdentifier: "ContactTableViewCell")
        
        getContact()
    }
    
    private func getContact() {
        let db = Firestore.firestore()
        db.collection("userdata").getDocuments(completion: { querySnapshot, error in
            if let err = error {
                print(err.localizedDescription)
            } else {
                for document in querySnapshot!.documents {
                    self.contacts.addObjects(from: [document.data() as Any])
                    self.tableContact.reloadData()
                }
            }
        })
    }
    
    @IBAction func didTapBtnClose(_ sender : UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell") as! ContactTableViewCell
        if contacts.count != 0 {
            let user = contacts[indexPath.row] as! NSDictionary
            let stringURL = user.value(forKey: "profile_image") as! String
            let displayName = user.value(forKey: "full_name") as! String
            let imageURL = URL(string: stringURL)
            cell.avatar.sd_setImage(with: imageURL, placeholderImage: #imageLiteral(resourceName: "bg.png"))
            cell.lblDisplayName.text = displayName
            listReceiver.add(user.value(forKey: "id") as Any)
//            print(listReceiver.count)
        }
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let receiverID = listReceiver[indexPath.row] as! String
        var isSender = false
        var listUsersJoinedChatGroup = ["":[:]]
        
        if receiverID == senderID {
            isSender = true // check if user are sender and receiver
            listUsersJoinedChatGroup = ["user\(self.senderID)" : ["id" : self.senderID, "message" : 0]]
        } else {
            listUsersJoinedChatGroup = ["user\(self.senderID)" : ["id" : self.senderID, "message" : 0], "user\(receiverID)" : ["id" : receiverID, "message" : 0]]
        }
        
        let db = Firestore.firestore()
        //Checks if channel exists, creates it if so.
        for data in listChannel {
            let channel = data as! NSDictionary
            let listUsers = channel.value(forKey: "users") as! NSDictionary

            if isSender {
                if (channel.value(forKey: "self_sender") as! Bool == isSender) {
                    let user = listUsers.allValues.first as! NSDictionary
                    let id = user.value(forKey: "id") as! String
                    if id == senderID {
                        self.channelID = channel.value(forKey: "id") as! String
                        self.dismiss(animated: true)
                        self.delegateMoveToView?.moveToChatView(channelID: self.channelID, receiverID: receiverID)
//                        self.delegateReloadView?.loadChannel()
                        return
                    }
                }
            } else {
                for data in listUsers {
                    let user = data.value as! NSDictionary
                    let id = user.value(forKey: "id") as! String
                    if id == receiverID {
                        self.channelID = channel.value(forKey: "id") as! String
                        self.dismiss(animated: true)
                        self.delegateMoveToView?.moveToChatView(channelID: self.channelID, receiverID: receiverID)
//                        self.delegateReloadView?.loadChannel()
                        return
                    }
                }
            }
        }
        
        let ref = db.collection("channel").document()
        ref.setData([
            "id" : ref.documentID,
            "name" : "",
            "created_at" : Date(),
            "updated_at" : Date(),
            "self_sender" : isSender,
            "users" : listUsersJoinedChatGroup])
        self.channelID = ref.documentID
        self.dismiss(animated: true)
        self.delegateMoveToView?.moveToChatView(channelID: self.channelID, receiverID: receiverID)
//        self.delegateReloadView?.loadChannel()
    }
//        db.whereField("users.user\(senderID)", isEqualTo: senderID)
//                .whereField("users.user\(receiverID)", isEqualTo: receiverID)
//                .getDocuments() { (querySnapshot, error) in
//                if let err = error {
//                    print(err.localizedDescription)
//                } else {
//                    if querySnapshot!.documents.count != 0 {
//                        self.channelID = querySnapshot!.documents.first!.documentID
//                        self.dismiss(animated: true)
//                        self.delegateMoveToView?.moveToChatView(channelID: self.channelID)
//                        self.delegateReloadView?.loadChannel()
//                    } else {
//                        let ref = db.collection("channels").document()
//                        ref.setData([
//                            "id" : ref.documentID,
//                            "name" : "",
//                            "created_at" : Date(),
//                            "updated_at" : Date(),
//                            "self_sender" : isSender,
//                            "users" : listUsersJoinedChatGroup])
//                        self.channelID = ref.documentID
//                        self.dismiss(animated: true)
//                        self.delegateMoveToView?.moveToChatView(channelID: self.channelID)
//                        self.delegateReloadView?.loadChannel()
//                    }
//                }
//        }
//    }
}
