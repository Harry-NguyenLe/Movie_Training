//
//  UserLikedExtendsion.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/6/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit
import CoreData

extension UserLiked {
    func updateUserLikedFilm(userID: String, filmID: Int) {
        self.uid = userID
        self.fid = Int64(filmID)
    }
}
