//
//  GlobalServices.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/3/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit

class GlobalServices: NSObject {
    static let httpService = HttpServices()
    static let filmService = FilmServices()
    static let userService = UserServices()
    static let localDatabse = LocalDatabase()
    static let myCustomPopupAlert = MyCustomPopupAlert()
    static let customMediaMessageCell = CustomMediaMessageCell()
}
