//
//  Message.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/22/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit
import MessageKit
import Firebase

struct MockUser: SenderType, Equatable {
    var senderId: String
    var displayName: String
}

struct ImageMediaItem: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = #imageLiteral(resourceName: "icons8-up_arrow.png")
    }
}

class Message :  MessageType, Equatable {
    
//    static func < (lhs: Message, rhs: Message) -> Bool {
//        print(lhs.sentDate > rhs.sentDate)
//        return lhs.sentDate > rhs.sentDate
//    }
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        if (lhs.messageId == rhs.messageId) {
            return true
        }
        return false
    }
    
    var sender: SenderType {
        return user
    }

    var messageId: String = ""

    var sentDate: Date

    var kind: MessageKind
    
    var content : String = ""
    
    var user : MockUser
    
    var downloadURL : URL?
    
    var status = "Delivered"
    
    init(user: MockUser, messageId: String? = nil, sentDate: Date? = nil, kind: MessageKind) {
        self.user = user
        self.messageId = messageId ?? ""
        self.sentDate = sentDate ?? Date()
        self.kind = kind
    }
    
    convenience init(user: MockUser, messageId: String? = nil, sentDate: Date? = nil, content: String) {
        self.init(user: user, messageId: messageId, sentDate: sentDate, kind: .text(content))
        self.content = content
        if verifyUrl(content) {
            self.downloadURL = URL.init(string: self.content)
        }
    }
    
    convenience init(user: MockUser, messageId: String? = nil, sentDate: Date? = nil, image: UIImage) {
        let mediaItem = ImageMediaItem(image: image)
        self.init(user: user, messageId: messageId, sentDate: sentDate, kind: .photo(mediaItem))
    }
    
    convenience init(user: MockUser, messageId: String? = nil, sentDate: Date? = nil, image: UIImage, url: URL) {
        let mediaItem = ImageMediaItem(image: image)
        self.init(user: user, messageId: messageId, sentDate: sentDate, kind: .photo(mediaItem))
        self.downloadURL = url
        self.content = url.absoluteString
    }
    
    func toArray() -> [String : Any] {
        let messages : [String : Any]
        messages = [
            "senderID" : user.senderId,
            "senderName" : sender.displayName,
            "text" : content,
            "create_at" : sentDate,
            "status" : status]
        return messages
    }
    
    func verifyUrl(_ urlString: String?) -> Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: urlString!, options: [], range: NSRange(location: 0, length: urlString!.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == urlString!.utf16.count
        } else {
            return false
        }
    }
}
