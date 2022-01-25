//
//  MyCustomTableViewCell.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/2/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit
import CoreData

class MyCustomTableViewCell: UITableViewCell {

    @IBOutlet weak var btnWatch: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblActor: UILabel!
    @IBOutlet weak var lblViews: UILabel!
    @IBOutlet var imageFilm: UIImageView!
    @IBOutlet weak var btnLike: MyCustomLikeButton!
    
    var isReuse = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        let imageView = UIImageView(image: UIImage(named: "bg.png"))
//        imageView.contentMode = .scaleToFill
//        self.backgroundView = imageView
        btnWatch.layer.cornerRadius = 5
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.btnLike.setImage(UIImage(named: "ic_like@3x.png"), for: .normal)
        self.btnLike.setTitle("  Thích", for: .normal)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    func updateData(data: NSDictionary) {
//        self.lblTitle.text = data.value(forKey: "title") as? String
//        self.lblDescription.text = data.value(forKey: "description") as? String
//        self.lblActor.text = "Diễn viên: " + ((data.value(forKey: "actor") as? String)!)
//        self.lblCategory.text = "Thể loại: " + ((data.value(forKey: "category") as? String)!)
//        imageFilm.sd_setImage(with: URL(string: (data.value(forKey: "image") as? String)!), placeholderImage: nil)
//
//    }
    
    func updateData(data: FilmData) {
        self.lblTitle.text = data.title
        self.lblDescription.text = data.des
        self.lblActor.text = "Diễn viên: \(data.actor ?? "")"
//        self.lblViews.text = "Lượt xem: " + (data.duration ?? "60") + " minute"
        self.lblViews.text = "Lượt xem: \(String(data.views))"
        self.imageFilm.sd_setImage(with: URL(string: data.image ?? ""), placeholderImage: nil)
        self.btnWatch.tag = Int(data.id)
        self.btnLike.btn_id = Int(data.id)
    }
    
    func updateFilmLiked(data: UserLiked) {
        if (data.fid == self.btnLike.btn_id) {
            self.btnLike.isLiked = true
//            self.btnLike.setImage(UIImage(named: "ic_like_orange@3x.png"), for: .normal)
//            self.btnLike.setTitle("  Đã thích", for: .normal)
        }
    }
    
//    @IBAction func didTapButtonLike(_ sender: UIButton) {
//        let btnLike = sender
//        btnLike.setImage(UIImage(named: "ic_like_orange.png"), for: .normal)
//        btnLike.setTitle("  Đã thích", for: .normal)
//        btnLike.isEnabled = false
//        if UserDefaults.standard.value(forKey: "uid") != nil {
//            let userLiked = NSEntityDescription.insertNewObject(forEntityName: "UserLiked", into: GlobalServices.localDatabse.manageObjectContext) as! UserLiked
//            userLiked.updateUserLikedFilm(userID: UserDefaults.standard.value(forKey: "uid") as! Int, filmID: btnLike.tag)
//            GlobalServices.localDatabse.saveLocalDataBase()
//        }
//    }
}
