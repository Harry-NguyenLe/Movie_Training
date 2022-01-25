//
//  FilmDataExtension.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/3/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import Foundation
import CoreData

extension FilmData {
    func updateDataFromDic(dic: NSDictionary) {
        if let value = dic["id"] as? Int64 {
            self.id = value
        }
        if let value = dic["title"] as? String {
            self.title = value
        }
        if let value = dic["link"] as? String {
            self.link = value
        }
        if let value = dic["image"] as? String {
            self.image = value
        }
        if let value = dic["description"] as? String {
            self.des = value
        }
        if let value = dic["actor"] as? String {
            self.actor = value
        }
        if let value = dic["category"] as? String {
            self.category = value
        }
        if let value = dic["director"] as? String {
            self.director = value
        }
        if let value = dic["manufacturer"] as? String {
            self.manufacturer = value
        }
        if let value = dic["views"] as? Int64 {
            self.views = value
        }
        if let value = dic["duration"] {
            return self.duration = value as? String
        }
    }
}
