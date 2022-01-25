//
//  ChannelsViewController.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/22/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit
import Firebase

protocol ReloadChannelsViewDelegate : AnyObject {
    func setViewState()
    func loadChannel()
}

protocol PushToViews : AnyObject {
    func moveToChatView(channelID : String, receiverID: String)
}

class ChannelsViewController: UIViewController, ReloadChannelsViewDelegate, PushToViews, UITableViewDataSource, UITableViewDelegate {
    
//    deinit {
//        listener?.remove()
//    }
    
    @IBOutlet weak var btnAddChannel : UIBarButtonItem!
    @IBOutlet weak var btnCloseChannel : UIBarButtonItem!
    @IBOutlet weak var tableChannel : UITableView!
    
    let listChannel = NSMutableArray()
    let dic = NSMutableDictionary()
    let uid = UserDefaults.standard.value(forKey: "uid") as! String
    let userName = UserDefaults.standard.value(forKey: "name") as! String
    let avatarUserPath = UserDefaults.standard.value(forKey: "profile_image") as! String
    let avatarCurrentUser = UIImageView()
    
    private var listener: ListenerRegistration?
    private var reference: CollectionReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableChannel.delegate = self
        self.tableChannel.dataSource = self
        self.tableChannel.register(UINib(nibName: "ChannelTableViewCell", bundle: nil), forCellReuseIdentifier: "ChannelTableViewCell")
        self.loadChannel()
        channelListener()
//        loadChannel()
    }
    
    private func channelListener() {
        let db = Firestore.firestore()
        reference = db.collection("channel")
        listener = reference!.whereField("users.user\(uid).id", isEqualTo: uid).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                return print(error!.localizedDescription)
            }
            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.tableChannel.reloadData()
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        switch change.type {
        case .modified:
            self.dic.setValue(change.document.data(), forKey: change.document.documentID)
//            self.listChannel.addObjects(from: [change.document.data() as Any])
            self.tableChannel.reloadData()
        default:
            break
        }
    }
    
    func setViewState() {
        btnAddChannel.isEnabled = true
        navigationController?.navigationBar.alpha = 1
    }
    
    func moveToChatView(channelID : String, receiverID: String) {
        let sv = UIViewController.displaySpinner(onView: self.view)
        let chatSV = UIStoryboard.init(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatView") as! ChatViewController
        chatSV.channelID = channelID
        chatSV.receiverID = receiverID
        self.navigationController?.pushViewController(chatSV, animated: true)
        UIViewController.removeSpinner(spinner: sv)
    }
    
    func loadChannel() {
        let sv = UIViewController.displaySpinner(onView: self.view)
        self.dic.removeAllObjects()
        self.listChannel.removeAllObjects()
        let db = Firestore.firestore()
        let ref = db.collection("channel")
        ref.whereField("users.user\(uid).id", isEqualTo: uid).getDocuments() { (querySnapshot, error) in
            if let err = error {
                print(err.localizedDescription)
            } else {
                for document in querySnapshot!.documents {
                    self.dic.setValue(document.data(), forKey: document.documentID)
                    self.listChannel.addObjects(from: [document.data() as Any])
                    self.tableChannel.reloadData()
                }
                UIViewController.removeSpinner(spinner: sv)
            }
        }
        
    }
    
    @IBAction func didTapBtnCloseChannel(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func didTapBtnAddChannel(_ sender: UIButton) {
//        sender.isEnabled = false
//        let popvc = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "PopupView") as! PopupViewController
//        popvc.delegate = self
//        self.addChild(popvc)
//        popvc.view.center = self.view.center
//        self.view.addSubview(popvc.view)
//        navigationController?.navigationBar.alpha = 0.5
//        popvc.didMove(toParent: self)
        
        let contactSV = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ContactView") as! ListContactsViewController
        contactSV.listChannel = self.listChannel
        contactSV.delegateMoveToView = self
        contactSV.delegateReloadView = self
//            self.navigationController?.pushViewController(contactSV, animated: true)
            self.present(contactSV, animated: true, completion: nil)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dic.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelTableViewCell", for: indexPath) as! ChannelTableViewCell
        cell.lblNewMessage.isHidden = true
        cell.lblNewMessage.text = ""
        if dic.count != 0 {
            let channel = dic.value(forKey: dic.allKeys[indexPath.row] as! String) as! NSDictionary
//            let channel = listChannel[indexPath.row] as! NSDictionary
            let listUsers = channel.value(forKey: "users") as! NSDictionary
            let isSender = channel.value(forKey: "self_sender") as! Bool
            
            // check if user are sender and receiver
            if isSender {
                let imageURL = UserDefaults.standard.value(forKey: "profile_image") as! String
                cell.lblUserID.text = uid
                cell.lblChannelName.text = UserDefaults.standard.value(forKey: "name") as? String
                cell.avatar.sd_setImage(with: URL(string: imageURL), placeholderImage: #imageLiteral(resourceName: "bg@2x.png"))
            } else {
                loadUserInfo(users: listUsers, lblDisplayName: cell.lblChannelName, avatar: cell.avatar, lblUserID: cell.lblUserID, lblNewMsg: cell.lblNewMessage)
            }
        }
        return cell
    }
    
    private func loadUserInfo(users: NSDictionary, lblDisplayName: UILabel, avatar: UIImageView, lblUserID: UILabel, lblNewMsg: UILabel) {
        for data in users {
            let user = data.value as! NSDictionary
            let id = user.value(forKey: "id") as! String
            if id != self.uid {
                Firestore.firestore().collection("userdata").whereField("id", isEqualTo: id).getDocuments { (querySnapshot, error) in
                    if let err = error {
                        print(err.localizedDescription)
                    } else {
                        for document in querySnapshot!.documents {
                            let userID = document.get("id") as! String
                            let imageURL = document.get("profile_image") as! String
                            let displayName = document.get("full_name") as! String
                            lblUserID.text = userID
                            lblDisplayName.text = displayName
                            avatar.sd_setImage(with: URL(string: imageURL), placeholderImage: #imageLiteral(resourceName: "bg@3x.png"))
                        }
                    }
                }
            } else {
                let numberOfNewMsg = user.value(forKey: "message") as! Int
                if numberOfNewMsg > 0 {
                    lblNewMsg.isHidden = false
                    lblNewMsg.text = "\(numberOfNewMsg) new messages"
                } else {
                    lblNewMsg.isHidden = true
                    lblNewMsg.text = ""
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ChannelTableViewCell
        let chatSV = UIStoryboard.init(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatView") as! ChatViewController
        chatSV.channelID = dic.allKeys[indexPath.row] as! String
        chatSV.channelName = cell.lblChannelName.text!
        chatSV.receiverID = cell.lblUserID.text!
        chatSV.delegate = self
        let db = Firestore.firestore()
        let ref = db.collection("userdata").document(uid)
        ref.updateData(["status" : "Connected to chat group"])
        loadMessageState(channelID: dic.allKeys[indexPath.row] as! String, otherSender: cell.lblUserID.text!)
        self.navigationController?.pushViewController(chatSV, animated: true)
    }
    
    private func loadMessageState(channelID: String, otherSender: String) {
        let db = Firestore.firestore()
        let ref = db.collection(["channel", channelID, "thread"].joined(separator: "/"))
        db.collection("channel").document(channelID).updateData(["users.user\(uid).message" : 0]) { error in
            if let err = error {
                print(err.localizedDescription)
            }
        }
        
        ref.whereField("senderID", isEqualTo: otherSender).getDocuments() { querySnapshot, error in
            if let err = error {
                print(err.localizedDescription)
            } else {
                for document in querySnapshot!.documents {
                    ref.document(document.documentID).updateData(["status" : "Read"])
                }
                
            }
        }
    }
}
