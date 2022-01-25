//
//  FilmDetailViewController.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/3/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit
import CoreData

class FilmDetailViewController: UIViewController {

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
//    var videoPlayer = YouTubePlayerView(frame: videoView)
    
    weak var delegate: ReloadViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
        //UIApplication.statusBarBackgroundColor = UIColor.orange
//        self.navigationController?.navigationBar.backItem?.hidesBackButton = false
        loadFilmDetail()
        checkFilmLiked()
        
        if calculateMaxLines() <= 3 {
            btnMoreDetails.isHidden = true
        }
    }
    
    func loadFilmDetail() {
        GlobalServices.localDatabse.fetchObjectWith(className: "FilmData", predicate: NSPredicate(format: "id == %@", String(film_ID))) { (filmArray) in
            if let film = filmArray?.firstObject as? FilmData {
                self.title = film.title
                self.lblTitle.text = film.title
                self.lblViews.text = "Lượt xem: \(film.views)"
                self.lblGenres.attributedText = ("Thể loại: " + film.category!).withBoldText(text: "Thể loại: ", font: UIFont(name:"Open Sans",size:11))
                self.lblActor.attributedText = ("Diễn viên: \( film.actor!)").withBoldText(text: "Diễn viên: ", font: UIFont(name:"Open Sans",size:11))
//                self.lblActor.font = UIFont(name:"Open Sans",size:13)
                self.lblDirector.attributedText = ("Đạo diễn: " + film.director!).withBoldText(text: "Đạo diễn: ", font: UIFont(name:"Open Sans",size:11))
                self.lblManufacturer.attributedText = ("Nhà sản xuất: \( film.manufacturer!)").withBoldText(text: "Nhà sản xuất: ", font: UIFont(name:"Open Sans",size:11))
                self.lblDuration.attributedText = ("Thời lượng xem: \( (film.duration ?? "60")) minute").withBoldText(text: "Thời lượng xem: ", font: UIFont(name:"Open Sans",size:11))
                self.lblDes.text = film.des
                self.imageFilm.sd_setImage(with: URL(string: film.image!), placeholderImage: nil)
                videoView.load(withVideoId: (film.link?.youtubeID)!)
//                videoView.load(withVideoId: "X-TSAALk82U")
            }
        }
    }
    
    func checkFilmLiked() {
        let predicate = NSPredicate(format:"uid == %@ && fid == %@", UserDefaults.standard.string(forKey: "uid")!, String(film_ID))
        GlobalServices.localDatabse.fetchObjectWith(className: "UserLiked", predicate: predicate) { (items) in
            if (items != nil) {
                btnLike.setImage(UIImage(named: "ic_like_orange.png"), for: .normal)
                btnLike.setTitle("  Đã thích", for: .normal)
                btnLike.isEnabled = false
            }
        }
    }
    
    @IBAction func didTapBtnMoreDetails(_ sender: UIButton) {
        lblDes.numberOfLines = calculateMaxLines()
        sender.isHidden = true
    }
    
    @IBAction func didTapButtonLike(_ sender: MyCustomLikeButton) {
        sender.setImage(UIImage(named: "ic_like_orange.png"), for: .normal)
        sender.setTitle("  Đã thích", for: .normal)
        sender.isEnabled = false
//        let userLiked = NSEntityDescription.insertNewObject(forEntityName: "UserLiked", into: GlobalServices.localDatabse.manageObjectContext) as! UserLiked
//        userLiked.updateUserLikedFilm(userID: UserDefaults.standard.value(forKey: "uid") as! String, filmID: film_ID)
//        GlobalServices.localDatabse.saveLocalDataBase()
        self.delegate?.loadUserLikedFilm()
    }
    
    func calculateMaxLines() -> Int {
        let maxSize = CGSize(width: lblDes.frame.size.width, height: CGFloat(Float.infinity))
        let charSize = lblDes.font.lineHeight
        let text = (lblDes.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: lblDes.font!], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
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

extension UIApplication {
    class var statusBarBackgroundColor: UIColor? {
        get {
            return (shared.value(forKey: "statusBar") as? UIView)?.backgroundColor
        } set {
            (shared.value(forKey: "statusBar") as? UIView)?.backgroundColor = newValue
        }
    }
}


