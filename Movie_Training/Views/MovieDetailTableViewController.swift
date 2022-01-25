//
//  MovieDetailTableViewController.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/9/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit
import CoreData

class MovieDetailTableViewController: UITableViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblViews: UILabel!
    @IBOutlet weak var lblGenres: UILabel!
    @IBOutlet weak var lblActor: UILabel!
    @IBOutlet weak var lblDirector: UILabel!
    @IBOutlet weak var lblManufacturer: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblDes: UILabel!
    @IBOutlet weak var btnLike: MyCustomLikeButton!
    @IBOutlet weak var btnMoreDetails: UIButton!
    @IBOutlet weak var videoView: WKYTPlayerView!
    @IBOutlet weak var imageFilm: UIImageView!
    
    var film_ID = 0
    var isExpand = false
    
    weak var delegate: ReloadViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let imageView = UIImageView(image: UIImage(named: "bg@3x.png"))
        imageView.contentMode = .scaleToFill
        self.tableView.backgroundView = imageView
        self.btnMoreDetails.underline()
//        if let title = self.btnMoreDetails.titleLabel?.text{
//            self.btnMoreDetails.setAttributedTitle(title.getUnderLineAttributedText(), for: .normal)
//        }
        
        loadFilmDetail()
        checkFilmLiked()
        
        if calculateMaxLines() <= 4 {
            btnMoreDetails.isHidden = true
        }
    }

    func loadFilmDetail() {
        GlobalServices.localDatabse.fetchObjectWith(className: "FilmData", predicate: NSPredicate(format: "id == %@", String(film_ID))) { (filmArray) in
            if let film = filmArray?.firstObject as? FilmData {
                let data = film as NSManagedObject
                let views = film.views + 1
                self.title = film.title
                self.lblTitle.text = film.title
                self.lblViews.text = "Lượt xem: \(views)"
                self.lblGenres.attributedText = ("Thể loại: " + film.category!).withBoldText(text: "Thể loại: ", font: UIFont(name:"Open Sans",size:12))
                self.lblActor.attributedText = ("Diễn viên: \( film.actor!)").withBoldText(text: "Diễn viên: ", font: UIFont(name:"Open Sans",size:12))
                //                self.lblActor.font = UIFont(name:"Open Sans",size:13)
                self.lblDirector.attributedText = ("Đạo diễn: " + film.director!).withBoldText(text: "Đạo diễn: ", font: UIFont(name:"Open Sans",size:12))
                self.lblManufacturer.attributedText = ("Nhà sản xuất: \( film.manufacturer ?? "")").withBoldText(text: "Nhà sản xuất: ", font: UIFont(name:"Open Sans",size:12))
                self.lblDuration.attributedText = ("Thời lượng xem: \( (film.duration ?? "60")) minute").withBoldText(text: "Thời lượng xem: ", font: UIFont(name:"Open Sans",size:12))
                self.lblDes.text = film.des
                self.imageFilm.sd_setImage(with: URL(string: film.image!), placeholderImage: nil)
                videoView.load(withVideoId: (film.link?.youtubeID)!)
                //                videoView.load(withVideoId: "X-TSAALk82U")
                
                if !Reachability.isConnectedToNetwork() {
                    data.setValue(views, forKey: "views")
                    GlobalServices.localDatabse.saveLocalDataBase()
                    self.delegate?.loadDataFromLocalDB()
                }
            }
        }
    }
    
    func checkFilmLiked() {
        let predicate = NSPredicate(format:"uid == %@ && fid == %@", UserDefaults.standard.string(forKey: "uid")!, String(film_ID))
        GlobalServices.localDatabse.fetchObjectWith(className: "UserLiked", predicate: predicate) { (items) in
            if (items != nil) {
                btnLike.isLiked = true
            }
        }
    }
    
    @IBAction func didTapBtnMoreDetails(_ sender: UIButton) {
        lblDes.numberOfLines = calculateMaxLines()
        sender.isHidden = true
        self.isExpand = true
        self.tableView.beginUpdates()
        self.tableView.reloadRows(at: [NSIndexPath(row: 1, section: 0) as IndexPath], with: UITableView.RowAnimation.none)
        self.tableView.endUpdates()
    }
    
    @IBAction func didTapButtonLike(_ sender: MyCustomLikeButton) {
        let sv = UIViewController.displaySpinner(onView: self.view)
        if UserDefaults.standard.value(forKey: "uid") != nil {
            sender.isLiked = !sender.isLiked
            if (sender.isLiked) {
                let userLiked = NSEntityDescription.insertNewObject(forEntityName: "UserLiked", into: GlobalServices.localDatabse.manageObjectContext) as! UserLiked
                userLiked.updateUserLikedFilm(userID: UserDefaults.standard.value(forKey: "uid") as! String, filmID: film_ID)
                GlobalServices.localDatabse.saveLocalDataBase()
                self.delegate?.loadUserLikedFilm()
            } else {
                let predicate = NSPredicate(format:"uid == %@ && fid == %@", UserDefaults.standard.string(forKey: "uid")!, String(film_ID))
                GlobalServices.localDatabse.fetchObjectWith(className: "UserLiked", predicate: predicate) { (items) in
                    if (items != nil) {                    GlobalServices.localDatabse.manageObjectContext.delete(items?.firstObject as! NSManagedObject)
                        GlobalServices.localDatabse.saveLocalDataBase()
                        self.delegate?.loadUserLikedFilm()
                    }
                    
                }
            }
        }
        UIViewController.removeSpinner(spinner: sv)
    }
    
    func calculateMaxLines() -> Int {
        let maxSize = CGSize(width: lblDes.frame.size.width, height: CGFloat(Float.infinity))
        let charSize = lblDes.font.lineHeight
        let text = (lblDes.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: lblDes.font!], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            if (isExpand) {
                return (CGFloat(375 + (lblDes.numberOfLines * 18))) - lblDes.frame.size.height
            } else {
                return 375
            }
        } else {
            return 400
        }
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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





