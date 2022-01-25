//
//  UserDataExtension.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/13/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit

extension UserData {
    func updataUserInfo(data: NSDictionary) {
        if let value = data["id"] as? String {
            self.id = value
        }
        if let value = data["email"] as? String {
            self.email = value
        }
        if let value = data["password"] as? String {
            self.password = value
        }
        if let value = data["full_name"] as? String {
            self.full_name = value
        }
        if let value = data["gender"] as? String {
            self.gender = value
        }
        if let value = data["birthday"] as? String {
            self.birthday = value
        }
        if let value = data["created_at"] as? String {
            self.created_at = value
        }
        if let value = data["updated_at"] as? String {
            self.updated_at = value
        }
        if let value = data["access_token"] as? String {
            self.access_token = value
        }
    }
}
