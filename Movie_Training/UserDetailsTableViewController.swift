//
//  UserDetailsTableViewController.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/16/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit
import Firebase

class UserDetailsTableViewController: UITableViewController {

    let userArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
//        saveUserToCloudFireStore()
//        saveUserToRealtimeDatabase()
//        getDataFireStore()
//        setExample1()
//        loadUser()
        setExample1()
    }
    
    func saveUserToRealtimeDatabase() {
        GlobalServices.localDatabse.fetchObjectWith(className: "UserData") { (items) in
            if items != nil {
                for item in items! {
                    let userData = item as! UserData
                    let db = Database.database()
                    var ref : DatabaseReference!
                    ref = db.reference()
                    ref.child("userdata").child(userData.id!).setValue(["id" : userData.id!, "full_name" : userData.full_name!, "gender" : userData.gender ?? "N/A", "email" : userData.email ?? "N/A", "password" : userData.password ?? "N/A", "birthDay" : userData.birthday ?? "N/A", "profile_image" : userData.profile_image ?? "N/A", "access_token" : userData.access_token ?? "N/A", "created_at" : userData.created_at ?? "N/A" , "updated_at" : userData.updated_at ?? "N/A"])
                    }
                }
                userArray.addObjects(from: items as! [Any])
                self.tableView.reloadData()
            
        }
    }
    
    func saveUserToCloudFireStore() {
        GlobalServices.localDatabse.fetchObjectWith(className: "UserData") { (items) in
            if items != nil {
                for item in items! {
                    let userData = item as! UserData
                    let db = Firestore.firestore()
                    db.collection("userdata").document(userData.id!).setData(["id" : userData.id!, "full_name" : userData.full_name!, "gender" : userData.gender ?? "N/A", "email" : userData.email ?? "N/A", "password" : userData.password ?? "N/A", "birthDay" : userData.birthday ?? "N/A", "profile_image" : userData.profile_image ?? "N/A", "access_token" : userData.access_token ?? "N/A", "created_at" : userData.created_at ?? "N/A" , "updated_at" : userData.updated_at ?? "N/A"]) { error in
                        if let err = error {
                            GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "Error!", message: err.localizedDescription)
                        } else {
                            GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "", message: "Saved!")
                        }
                    }
                }
                userArray.addObjects(from: items as! [Any])
                self.tableView.reloadData()
            }
        }
    }
    
    func setFireStore() {
        let db = Firestore.firestore()
        var ref : DocumentReference! = nil
        ref = db.collection("filmdata").addDocument(data: ["name" : "B", "age" : "22", "gender" : "female"]) { error in
            if let err = error {
                GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "Error!", message: err.localizedDescription)
            } else {
                GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "", message: "\(ref.documentID)")
            }
        }
    }
    
    func setExample1() {
        let db = Firestore.firestore()
        db.collection("cities").document("CA").setData([
            "name": "Los Angeles",
            "state": ["CA" : true, "BA" : true],
            "country": "USA"
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
//        db.collection("cities").document("LA").setData([ "capital": false ], merge: true)
//        db.collection("channels").addDocument(data: ["name" : "text"]).collection("thread").addDocument(data: ["senderID:" : "1", "senderName" : "test", "create_at" : Date(), "text" : "testing"])
    }
    
    func getDataFireStore() {
        let db = Firestore.firestore()
        db.collection("cities").getDocuments() { (querySnapshot, error) in
            if let err = error {
                GlobalServices.myCustomPopupAlert.displayMessage(onViewController: self, title: "Error!", message: err.localizedDescription)
            } else {
                for document in querySnapshot!.documents {
                    self.userArray.addObjects(from: [document.data() as Any])
                    self.tableView.reloadData()
                    print("\(document.documentID) : \(document.data())")
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserTableViewCell
        if userArray.count != 0 {
//            let user = userArray[indexPath.row] as! NSDictionary
//            cell.lblId.text = "\(user.value(forKey: "name") as! String)"
//            cell.lblEmail.text = "\(user.value(forKey: "state") as! String)"
//            cell.lblName.text = "\(user.value(forKey: "country") as! String)"
        }

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
