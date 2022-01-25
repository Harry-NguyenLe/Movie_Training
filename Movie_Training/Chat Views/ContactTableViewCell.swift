//
//  ContactTableViewCell.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/28/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var avatar : UIImageView!
    @IBOutlet weak var lblDisplayName :UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.avatar.layer.cornerRadius = self.avatar.frame.size.width / 2
        self.avatar.clipsToBounds = true
        self.avatar.layer.borderWidth = 3
        self.avatar.layer.borderColor = UIColor(red: 69/255, green: 214/255, blue: 93/255, alpha: 1.0).cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
