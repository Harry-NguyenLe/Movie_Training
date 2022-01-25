//
//  UILabelExtension.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 5/15/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit

extension UILabel {
    func underline() {
        if let textString = self.text {
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
    }
}
