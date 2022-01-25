//
//  LeftMenuTableViewCell.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/10/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit

class LeftMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var lblIconTitle: UILabel!
    @IBOutlet weak var iconView : UIImageView!
    @IBOutlet weak var newMsgView : UIView!
    @IBOutlet weak var lblNewMsg : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.newMsgView.layer.cornerRadius = self.newMsgView.frame.size.width / 2
        self.newMsgView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
