//
//  TestViewController.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/21/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit
import Firebase

class TestViewController: UIViewController  {

    @IBOutlet weak var fcmTokenMessage : UILabel!
    @IBOutlet weak var instanceIDTokenMessage : UILabel!
    
    var imagePicker: UIImagePickerController!
//    var storeRef : StorageReference! = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(displayFCMToken(notification: )), name: Notification.Name("FCMToken"), object: nil)
    }
    
    
    @IBAction func didBtnSendMsg() {
//        InstanceID.instanceID().instanceID { (result, error) in
//            if let error = error {
//                print("Error fetching remote instance ID: \(error)")
//            } else if let result = result {
//                print("Remote instance ID token: \(result.token)")
//                self.instanceIDTokenMessage.text  = "Remote InstanceID token: \(result.token)"
//            }
//        }
//
//        Messaging.messaging().subscribe(toTopic: "Fooo") { error in
//            print("Subscrive to Fooo Topic")
//        }
        
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString : [String : Any]  = ["to" : " d2YTK-btQOs:APA91bHHQlH_WgtH95i_gea-s0c2o2VIJZOvCiFwl7jQF2I5CN6DsIPU1A8UJAwpE2AkcD82buzTLBHnAc4Om1iaq52rz_fsAk0_BI0p5Craa06-9XTi9cfO-4pOlWTdA_pnVx7gma3z", "notification" : ["title" : "Hello", "body" : "Testing"], "data" : ["user" : "test_id"]]

        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: paramString, options: [.prettyPrinted])
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAA3JY25tI:APA91bFk5a_uqNNYpl5-ZvC3AkhJbR9QW7TSG1z8yE2Iqn-WuHQUbmlHyhW_a4_5IJ08QXEeoxxM8BqtyZbn76ZWeziPjdiU93kvw0mOiID4wa-B_NLgIgO_U1tHB34CCB_II16-TTbf", forHTTPHeaderField: "Authorization")

        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error: \(error!.localizedDescription)")
                return
            }

            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response: \(String(describing: response))")
            }

            let responseString = String(data: data, encoding: .utf8)
            print("responseString: \(String(describing: responseString))")
        }
        task.resume()
    }
    
    @objc func displayFCMToken(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        print("Notification name: \(Notification.Name("FCMToken"))")
        if let fcmToken = userInfo["token"] as? String {
            self.fcmTokenMessage.text = "Received FCM token: \(fcmToken)"
        }
    }
}
