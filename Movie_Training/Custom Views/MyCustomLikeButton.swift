//
//  MyCustomLikeButton.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/10/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit

class MyCustomLikeButton: UIButton {

    var btn_id: Int = 0
    var isLiked: Bool = false {
        didSet {
            if (self.isLiked) {
                self.setImage(UIImage(named: "ic_like_orange@3x.png"), for: .normal)
                self.setTitle("  Đã thích", for: .normal)
            } else {
                self.setImage(UIImage(named: "ic_like@3x.png"), for: .normal)
                self.setTitle("  Thích", for: .normal)
            }
        }
    }
}
