//
//  ChatViewController.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/22/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit
import Firebase
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController, MessageInputBarDelegate, MessagesDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    deinit {
        userListener?.remove()
        messageListener?.remove()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    let uid = UserDefaults.standard.value(forKey: "uid") as! String
    let senderName = UserDefaults.standard.value(forKey: "name") as! String
    var channelID = ""
    var channelName = ""
    var receiverID = ""
    var senderState = ""
    var device_token = ""
    let outgoingAvatarOverlap: CGFloat = 17.5
    
    weak var delegate : ReloadChannelsViewDelegate?
    
    var imagePicker: UIImagePickerController!
    
    private var reference: CollectionReference?
    private var observeUser: DocumentReference?
    private var storageRef: StorageReference?
    
    private var messages: [Message] = []
    private var messageListener: ListenerRegistration?
    private var userListener: ListenerRegistration?
    
    private var isFirstLoad = true
//    var percentComplete = 0.0
    let progressView = UIProgressView()
    
//    let refreshControl = UIRefreshControl()
    
    private var isSendingPhoto = false {
        didSet {
            DispatchQueue.main.async {
                self.messageInputBar.leftStackViewItems.forEach { item in
                    let button = item as! InputBarButtonItem
                    button.isEnabled = !self.isSendingPhoto
                }
            }
        }
    }
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    enum ImageSource {
        case photoLibrary
        case camera
    }
    
    override func viewDidLoad() {
        messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: CustomMessagesFlowLayout())
        messagesCollectionView.register(CustomCell.self)
        messagesCollectionView.register(CustomMediaMessageCell.self)
        super.viewDidLoad()
        
        // configure
        self.hidesKeyboard()
        configureMessageCollectionView()
        configureMessageInputBar()
//        configNavigationBar()
        
        // observer and return data if it changes
        let path = UserDefaults.standard.value(forKey: "profile_image") as! String
        let db = Firestore.firestore()
        let storage = Storage.storage()
        storageRef = storage.reference(withPath: path)
        
        observeUser = db.collection("userdata").document(receiverID)
        userListener = observeUser?.addSnapshotListener {
            querySnapshot, error in
            guard let snapshot = querySnapshot else {
                return GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "Error!", message: error!.localizedDescription)
            }
            
            self.device_token = snapshot.get("device_token") as! String
            self.senderState = snapshot.get("status") as! String
            
        }
        
        reference = db.collection(["channel", channelID, "thread"].joined(separator: "/"))
        messageListener = reference?.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                return GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "Error!", message: error!.localizedDescription)
            }
            
            snapshot.documentChanges.forEach { change in
//                self.reference?.document(change.document.documentID).delete()
                self.handleDocumentChange(change)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let db = Firestore.firestore()
        let ref = db.collection("userdata").document(uid)
        ref.updateData(["status" : "Online"])
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        if change.document.data().count != 0 {
            let timestamp = change.document.get("create_at") as! Timestamp
            let date : Date = timestamp.dateValue()
            let senderID = change.document.get("senderID") as! String
            let senderName = change.document.get("senderName") as! String
            let message = Message(user: .init(senderId: senderID, displayName: senderName), messageId: change.document.documentID,  sentDate: date, content: change.document.get("text") as! String)
            message.status = change.document.get("status") as! String
            switch change.type {
            case .added:
                if let url = message.downloadURL {
                    downloadImage(at: url, message: message) { [weak self] image in
                        guard let self = self else {
                            return
                        }
                        guard let image = image else {
                            return
                        }
                        
                        if self.isFirstLoad || !self.isFromCurrentSender(message: message) {
                            let mediaItem = ImageMediaItem(image: image)
                            message.kind = .photo(mediaItem)
                            self.insertMessage(message)
                        }
////                        self.messagesCollectionView.scrollToBottom()
                    }
                } else {
                    self.insertMessage(message)
                }
            default:
                break
            }
        }
    }
    
    private func downloadImage(at url: URL, message: Message, completion: @escaping (UIImage?) -> Void) {
        let ref = Storage.storage().reference(forURL: url.absoluteString)
        let imageView = UIImageView()
//        let sv = UIViewController.displaySpinner(onView: imageView)
        if isFirstLoad {
            imageView.sd_setImage(with: ref)
            completion(imageView.image)
        } else {
            imageView.sd_setImage(with: ref)
            let megaByte = Int64(10 * 1024 * 1024)
            ref.getData(maxSize: megaByte) { data, error in
                guard let imageData = data else {
                    completion(nil)
                    return
                }

                completion(UIImage(data: imageData))
            }
        }
    }
    
//    private func loadMessageState(channelID: String, otherSender: String) {
//        let db = Firestore.firestore()
//        let ref = db.collection(["channel", channelID, "thread"].joined(separator: "/"))
//        db.collection("channel").document(channelID).updateData(["users.user\(uid).message" : 0]) { error in
//            if let err = error {
//                print(err.localizedDescription)
//            }
//        }
//        
//        ref.whereField("senderID", isEqualTo: otherSender).getDocuments() { querySnapshot, error in
//            if let err = error {
//                print(err.localizedDescription)
//            } else {
//                for document in querySnapshot!.documents {
//                    ref.document(document.documentID).updateData(["status" : "Read"])
//                }
//                
//            }
//        }
//    }
    
//    private func configNavigationBar() {
//        navigationItem.hidesBackButton = true
//        let newBackButton = UIBarButtonItem(title: "\(channelName)", style: .plain, target: self, action: #selector(self.backAction(sender: )))
//        navigationItem.leftBarButtonItem = newBackButton
//    }
//
//    @objc func backAction(sender : UIBarButtonItem) {
//        let db = Firestore.firestore()
//        db.collection(["channels", channelID, "thread"].joined(separator: "/")).getDocuments() { snapshotQuery, error in
//                guard let snapshotQuery = snapshotQuery else {
//                print(error!.localizedDescription)
//                    return
//                }
//
//                if snapshotQuery.count == 0 {
//                    db.collection("channels").document(self.channelID).delete()
//                }
//            self.navigationController?.popViewController(animated: true)
//        }
//    }
    
    @objc private func cameraButtonPressed() {
        let imageView = UIAlertController(title: "", message: "Select Image", preferredStyle: .actionSheet)
        imageView.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action:UIAlertAction) in
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                return GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "Error", message: "Device does not support camera")
            }
            self.selectImageFrom(.camera)
        }))
        imageView.addAction(UIAlertAction(title: "Photos", style: .default, handler: {(action:UIAlertAction) in
            self.selectImageFrom(.photoLibrary)
        }))
        imageView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(imageView, animated: true, completion: nil)
    }
    
    func selectImageFrom(_ source: ImageSource){
        messageInputBar.isHidden = true
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
    
    func configureMessageCollectionView() {
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.sectionInset = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8)
        
        // Hide the outgoing avatar and adjust the label alignment to line up with the messages
        layout?.setMessageOutgoingAvatarSize(.zero)
        layout?.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
        layout?.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)))
        
        // Set outgoing avatar to overlap with the message bubble
        layout?.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 18, bottom: outgoingAvatarOverlap, right: 0)))
        layout?.setMessageIncomingAvatarSize(CGSize(width: 30, height: 30))
        layout?.setMessageIncomingMessagePadding(UIEdgeInsets(top: -outgoingAvatarOverlap, left: -18, bottom: outgoingAvatarOverlap, right: 18))
    
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        
        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        
        //        messagesCollectionView.addSubview(refreshControl)
        //        refreshControl.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
    }
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
        
        messageInputBar.inputTextView.tintColor = .primaryColor
        messageInputBar.inputTextView.placeholder = "Aa"
        messageInputBar.sendButton.setTitleColor(.primaryColor, for: .normal)
        messageInputBar.sendButton.setTitleColor(
            UIColor.primaryColor.withAlphaComponent(0.3),
            for: .highlighted
        )
        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.inputTextView.tintColor = .primaryColor
        messageInputBar.inputTextView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        messageInputBar.inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
        messageInputBar.inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1.0
        messageInputBar.inputTextView.layer.cornerRadius = 16.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        configureInputBarItems()
    }
    
    private func configureInputBarItems() {
        let cameraItem = InputBarButtonItem(type: .system)
        cameraItem.tintColor = .primaryColor
        cameraItem.image = #imageLiteral(resourceName: "icons8-camera.png")
        cameraItem.addTarget(self, action: #selector(cameraButtonPressed), for: .primaryActionTriggered)
        cameraItem.setSize(CGSize(width: 60, height: 30), animated: false)
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false)
        
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.sendButton.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
        messageInputBar.sendButton.image = #imageLiteral(resourceName: "ic_up")
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.imageView?.layer.cornerRadius = 16
//        messageInputBar.middleContentViewPadding.right = -38
        let charCountButton = InputBarButtonItem().configure {
                $0.title = "0/140"
                $0.contentHorizontalAlignment = .right
                $0.setTitleColor(UIColor(white: 0.6, alpha: 1), for: .normal)
                $0.titleLabel?.font = UIFont.systemFont(ofSize: 10, weight: .bold)
                $0.setSize(CGSize(width: 50, height: 25), animated: false)
            }.onTextViewDidChange { (item, textView) in
                item.title = "\(textView.text.count)/140"
                let isOverLimit = textView.text.count > 140
                item.inputBarAccessoryView?.shouldManageSendButtonEnabledState = !isOverLimit // Disable automated management when over limit
                if isOverLimit {
                    item.inputBarAccessoryView?.sendButton.isEnabled = false
                }
                let color = isOverLimit ? .red : UIColor(white: 0.6, alpha: 1)
                item.setTitleColor(color, for: .normal)
        }
        let bottomItems = [.flexibleSpace, charCountButton]
//        messageInputBar.middleContentViewPadding.bottom = 8
        messageInputBar.setStackViewItems(bottomItems, forStack: .bottom, animated: false)
        
        // This just adds some more flare
        messageInputBar.sendButton
            .onEnabled { item in
                UIView.animate(withDuration: 0.3, animations: {
                    item.imageView?.backgroundColor = .primaryColor
                })
            }.onDisabled { item in
                UIView.animate(withDuration: 0.3, animations: {
                    item.imageView?.backgroundColor = UIColor(white: 0.85, alpha: 1)
                })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        messageInputBar.isHidden = false
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        messageInputBar.isHidden = false
        imagePicker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        
        if imagePicker.sourceType == .camera {
            UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }

        sendPhoto(selectedImage)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "Save error", message: error.localizedDescription)
        } else {
            print("Saved! Your image has been saved to your photos.")
        }
    }
    
    private func sendPhoto(_ image: UIImage) {
        self.isSendingPhoto = true
        let message = Message(user: MockUser(senderId: self.uid, displayName: self.senderName), image: image)
        self.insertMessage(message)
        self.messagesCollectionView.scrollToBottom()
    }
    
    private func saveMsgToServer(message : Message) {
        if self.senderState == "Connected to chat group" {
            message.status = "Read"
        }
        self.reference?.addDocument(data: message.toArray()) { error in
            if let err = error {
                print("error: \(err.localizedDescription)")
            } else {
                if message.status == "Delivered" {
                    self.updateUserNumberOfMessages()
//                    self.delegate?.loadChannel()
                }
                
                self.sendPushNotification(message : message)
            }
        }
        
        self.messagesCollectionView.scrollToBottom()
    }
    
    private func sendPushNotification(message: Message) {
        var params : [String : Any]
        
        switch message.kind {
        case .photo:
            params = ["to" : device_token,
                      "notification" : ["title" : senderName, "sound": "default"],
                      "data" : ["urlImageString" : message.downloadURL?.absoluteString],
                      "mutable_content": true,
                      "priority": "high"]
        default:
             params = ["to" : device_token,
                       "notification" : ["title" : senderName, "body" : message.content, "sound": "default"],
                       "mutable_content": true,
                       "priority": "high"]
        }

        GlobalServices.httpService.sendHttpRequestForPushNotification(param: params) { isOk, error, code, data  in
            if !isOk {
                print("error: \(error)")
            } else {
                print("responseString: \(error))")
            }
        }
    }
    
    private func updateUserNumberOfMessages() {
        let db = Firestore.firestore()
        let sfReference = db.collection("channel").document(self.channelID)
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let sfDocument: DocumentSnapshot
            do {
                try sfDocument = transaction.getDocument(sfReference)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let oldMessage = sfDocument.get("users.user\(self.receiverID).message") as? Int else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve message from snapshot \(sfDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            transaction.updateData(["users.user\(self.receiverID).message": oldMessage + 1], forDocument: sfReference)
            transaction.updateData(["updated_at": Date()], forDocument: sfReference)
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
                self.updateUserTotalOfNewMessages()
            }
        }
    }
    
    private func updateUserTotalOfNewMessages() {
        let db = Firestore.firestore()
        let sfReference = db.collection("userdata").document(self.receiverID)
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let sfDocument: DocumentSnapshot
            do {
                try sfDocument = transaction.getDocument(sfReference)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let oldMessage = sfDocument.get("new_message") as? Int else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve message from snapshot \(sfDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            transaction.updateData(["new_message" : oldMessage + 1], forDocument: sfReference)
            transaction.updateData(["updated_at": Date()], forDocument: sfReference)
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
    }
    
    func insertMessage(_ message: Message) {
//        guard !messages.contains(message) else {
//            return
//        }
        messages.append(message)
        messages.sort(by: { $0.sentDate < $1.sentDate })
        
        let isLatestMessage = messages.index(of: message) == (messages.count - 1)
        let shouldScrollToBottom = messagesCollectionView.scrollsToTop && isLatestMessage
        messagesCollectionView.reloadData()
       
        if shouldScrollToBottom {
            DispatchQueue.main.async {
                self.isFirstLoad = false
                self.messagesCollectionView.scrollToBottom()
            }
        }
        
//         Reload last section to update header/footer labels and insert a new one
//                messagesCollectionView.performBatchUpdates({
//                    messagesCollectionView.insertSections([messages.count - 1])
//                    if messages.count >= 2 {
//                        messagesCollectionView.reloadSections([messages.count - 2])
//                    }
//                }, completion: { [weak self] _ in
//                    if self?.isLastSectionVisible() == true {
//                        self?.messagesCollectionView.scrollToBottom(animated: true)
//                    }
//                })
    }
    
    func isLastSectionVisible() -> Bool {
        guard !messages.isEmpty else { return false }
        let lastIndexPath = IndexPath(item: 0, section: messages.count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }

    // MARK: - MessageInputBarDelegate
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let message = Message(user: .init(senderId: uid, displayName: senderName), content: inputBar.inputTextView.text)
        saveMsgToServer(message: message)
        inputBar.inputTextView.text = ""
    }
    
//    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
//        // Here we can parse for which substrings were autocompleted
//        let attributedText = messageInputBar.inputTextView.attributedText!
//        let range = NSRange(location: 0, length: attributedText.length)
//        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { (_, range, _) in
//
//            let substring = attributedText.attributedSubstring(from: range)
//            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
//            print("Autocompleted: `", substring, "` with context: ", context ?? [])
//        }
//
//        let components = inputBar.inputTextView.components
//        messageInputBar.inputTextView.text = String()
//        messageInputBar.invalidatePlugins()
//
//        // Send button activity animation
//        messageInputBar.sendButton.startAnimating()
//        messageInputBar.inputTextView.placeholder = "Sending..."
//        DispatchQueue.global(qos: .default).async {
//            // fake send request task
//            sleep(1)
//            DispatchQueue.main.async { [weak self] in
//                self?.messageInputBar.sendButton.stopAnimating()
//                self?.messageInputBar.inputTextView.placeholder = "Aa"
//                self?.insertMessages(components)
//                self?.messagesCollectionView.scrollToBottom(animated: true)
//            }
//        }
//    }
    
    // MARK: - Helpers
    
    func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
        return indexPath.section % 3 == 0 && !isPreviousMessageSameSender(at: indexPath)
    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return messages[indexPath.section].user == messages[indexPath.section - 1].user
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messages.count else { return false }
        return messages[indexPath.section].user == messages[indexPath.section + 1].user
    }
    
    func setTypingIndicatorViewHidden(_ isHidden: Bool, performUpdates updates: (() -> Void)? = nil) {
//        updateTitleView(title: "MessageKit", subtitle: isHidden ? "2 Online" : "Typing...")
        setTypingIndicatorViewHidden(isHidden, animated: true, whilePerforming: updates) { [weak self] success in
            if success, self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
    
    private func uploadImage(_ imageView: UIImageView, completion: @escaping (URL?) -> Void) {
        let storage = Storage.storage()
        let imageName = "\([uid, String(Date().timeIntervalSince1970).replacingOccurrences(of: ".", with: "")].joined()).jpg"
        guard let data = imageView.image!.jpegData(compressionQuality: 0.5) else {
            completion(nil)
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let storageRef = storage.reference(withPath: "chat_image/\(uid)\(receiverID)\(channelID)/\(imageName)")
        let uploadTask = storageRef.putData(data, metadata: metadata) { meta, error in
            guard let metadata = meta else {
                print(error!.localizedDescription)
                return
            }
            print("Upload complete! Here's some metadata: \(String(describing: metadata.bucket))")
            storageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    print(error!.localizedDescription)
                    return
                }
                //                completion("chat_image/\(imageName)")
                completion(downloadURL)
                print(downloadURL.absoluteString)
            }}
            uploadTask.observe(.progress, handler: { [ weak self ] snapshot in
                guard let strongSelf = self else { return }
                guard let progress = snapshot.progress else { return }
                let percentComplete = 100.0 * Double(progress.completedUnitCount)
                    / Double(progress.totalUnitCount)
                print(progress.completedUnitCount)
                strongSelf.progressView.progress = Float(percentComplete)
            })
            uploadTask.observe(.success, handler: { [ weak self ] snapshot in
                guard let strongSelf = self else { return }
                strongSelf.progressView.isHidden = true
                imageView.alpha = 1
            })
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if isSendingPhoto {
            if indexPath.section == messages.count - 1 {
                self.progressView.isHidden = false
                imageView.alpha = 0.5
                imageView.superview?.addSubview(self.progressView)
                self.progressView.constraint(equalTo: CGSize(width: 240, height: 3))
                self.progressView.centerInSuperview()
                uploadImage(imageView) { [weak self] url in
                    guard let self = self else {
                        return
                    }
                    
                    self.isSendingPhoto = false
                    
                    guard let url = url else {
                        return
                    }
                    
                    self.messages[indexPath.section].downloadURL = url
                    self.messages[indexPath.section].content = url.absoluteString
                    self.saveMsgToServer(message: self.messages[indexPath.section])
                    self.messagesCollectionView.scrollToBottom()
                }
            }
        }
    }
    
//    private func makeButton(named: String) -> InputBarButtonItem {
//        return InputBarButtonItem()
//            .configure {
//                $0.spacing = .fixed(10)
//                $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
//                $0.setSize(CGSize(width: 25, height: 25), animated: false)
//                $0.tintColor = UIColor(white: 0.8, alpha: 1)
//            }.onSelected {
//                $0.tintColor = .primaryColor
//            }.onDeselected {
//                $0.tintColor = UIColor(white: 0.8, alpha: 1)
//            }.onTouchUpInside {
//                print("Item Tapped")
//                let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//                let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//                actionSheet.addAction(action)
//                if let popoverPresentationController = actionSheet.popoverPresentationController {
//                    popoverPresentationController.sourceView = $0
//                    popoverPresentationController.sourceRect = $0.frame
//                }
//                self.navigationController?.present(actionSheet, animated: true, completion: nil)
//        }
//    }

//     MARK: - UICollectionViewDataSource
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError("Ouch. nil data source for messages")
        }

        // Very important to check this when overriding `cellForItemAt`
        // Super method will handle returning the typing indicator cell
        guard !isSectionReservedForTypingIndicator(indexPath.section) else {
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }

        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .custom = message.kind {
            let cell = messagesCollectionView.dequeueReusableCell(CustomCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        }
//        if case .photo = message.kind {
//            let cell = messagesCollectionView.dequeueReusableCell(CustomMediaMessageCell.self, for: indexPath)
//            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
//            return cell
//        }
        
        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    // MARK: - MessagesDataSource
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func currentSender() -> SenderType {
        return Sender(id: uid, displayName: senderName)
    }
    
    func messageForItem(at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        return messages[indexPath.section]
    }
    
    func cellTopLabelAttributedText(for message: MessageType,
                                    at indexPath: IndexPath) -> NSAttributedString? {
        
        if isTimeLabelVisible(at: indexPath) {
            print(MessageKitDateFormatter.shared.string(from: message.sentDate))
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
//        let date = MessageKitDateFormatter.shared.string(from: message.sentDate)
//        if indexPath.section % 3 == 0 {
//            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
//        }
        return nil
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        return NSAttributedString(string: "Read", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if !isPreviousMessageSameSender(at: indexPath) {
            let name = message.sender.displayName
            return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
        }
        return nil
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if !isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message) {
            return NSAttributedString(string: messages[indexPath.section].status, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
        }
        return nil
    }
}

extension ChatViewController : MessageCellDelegate {
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError("Ouch. nil data source for messages")
        }
        let indexPath = messagesCollectionView.indexPath(for: cell)
        let message = messagesDataSource.messageForItem(at: indexPath!, in: messagesCollectionView)
        
        if case .photo(let photoItem) = message.kind {
            if isSendingPhoto == false {
            let imageView = UIAlertController.init()
                imageView.addAction(UIAlertAction(title: "Save image to your Photos", style: .default, handler: {(action:UIAlertAction) in
                    UIImageWriteToSavedPhotosAlbum(photoItem.image!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                }))
            imageView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            print(photoItem.image as Any)
            self.present(imageView, animated: true, completion: nil)
            }
        }
    }
}

extension ChatViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isTimeLabelVisible(at: indexPath) {
            return 18
        }
        
//        let date = MessageKitDateFormatter.shared.string(from: message.sentDate)
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isFromCurrentSender(message: message) {
            return !isPreviousMessageSameSender(at: indexPath) ? 20 : 0
        } else {
            return !isPreviousMessageSameSender(at: indexPath) ? (20 + outgoingAvatarOverlap) : 0
        }
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return (!isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message)) ? 16 : 0
//        return 16
    }
    
//    func footerViewSize(for message: MessageType, at indexPath: IndexPath,
//                        in messagesCollectionView: MessagesCollectionView) -> CGSize {
//        return CGSize(width: 0, height: 8)
//    }
    
}

extension ChatViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath,
                         in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .primaryColor : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
       
        getAvatar(uid : message.sender.senderId, image: avatarView, indexPath: indexPath)
        avatarView.isHidden = self.isNextMessageSameSender(at: indexPath)
    }
    
    func getAvatar(uid : String, image: AvatarView, indexPath: IndexPath) {
        let placeholderImage = image
        placeholderImage.initials = "?"
        var path = ""
        let userRef = Firestore.firestore().collection("userdata").whereField("id", isEqualTo: uid)
        userRef.getDocuments { (querySnapshot, error) in
            DispatchQueue.main.async {
                guard let snapshot = querySnapshot,
                    error == nil else {
                        return print("error: \(error!)")
                }
                guard !snapshot.isEmpty else {
                    return print("results: 0")
                }
                
                let document = snapshot.documents.first
                path = document?.get("profile_image") as! String
                image.sd_setImage(with: URL(string: path), placeholderImage: placeholderImage.image)
            }
            
        }
        
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
//        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
//        return .bubbleTail(corner, .curved)
        
        var corners: UIRectCorner = []
        
        if isFromCurrentSender(message: message) {
            corners.formUnion(.topLeft)
            corners.formUnion(.bottomLeft)
            if !isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topRight)
            }
            if !isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomRight)
            }
        } else {
            corners.formUnion(.topRight)
            corners.formUnion(.bottomRight)
            if !isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topLeft)
            }
            if !isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomLeft)
            }
        }
        
        return .custom { view in
            let radius: CGFloat = 16
            let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            view.layer.mask = mask
        }
    }
    
    func configureAccessoryView(_ accessoryView: UIView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        // Cells are reused, so only add a button here once. For real use you would need to
        // ensure any subviews are removed if not needed
        accessoryView.subviews.forEach { $0.removeFromSuperview() }
        accessoryView.backgroundColor = .clear
        
        let shouldShow = Int.random(in: 0...10) == 0
        guard shouldShow else { return }
        
        let button = UIButton(type: .infoLight)
        button.tintColor = .primaryColor
        accessoryView.addSubview(button)
        button.frame = accessoryView.bounds
        button.isUserInteractionEnabled = false // respond to accessoryView tap through `MessageCellDelegate`
        accessoryView.layer.cornerRadius = accessoryView.frame.height / 2
        accessoryView.backgroundColor = UIColor.primaryColor.withAlphaComponent(0.3)
    }
    
//    func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
//        return { view in
//            view.layer.transform = CATransform3DMakeScale(2, 2, 2)
//            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
//                view.layer.transform = CATransform3DIdentity
//            }, completion: nil)
//        }
//    }
//
//    func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
//
//        return LocationMessageSnapshotOptions(showsBuildings: true, showsPointsOfInterest: true, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
//    }

}

extension UIColor {
    static let primaryColor = UIColor(red: 69/255, green: 214/255, blue: 93/255, alpha: 1.0)
}
