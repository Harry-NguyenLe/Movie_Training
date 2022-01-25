//
//  UIButtonExtension.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/15/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit

extension UIButton {
    func underline() {
        let attributedString = NSMutableAttributedString(string: (self.titleLabel?.text!)!)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle,
                                      value: NSUnderlineStyle.single.rawValue,
                                      range: NSRange(location: 0, length: (self.titleLabel?.text!.count)!))
        self.setAttributedTitle(attributedString, for: .normal)
    }
}
