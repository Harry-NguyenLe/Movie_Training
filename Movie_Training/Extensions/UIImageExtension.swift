//
//  UIImageExtension.swift
//  Movie_Training
//
//  Created by Kiem Nguyen on 6/5/19.
//  Copyright © 2019 Kiem Nguyen. All rights reserved.
//

import UIKit

extension UIImage {
    func imageWithAlpha(alpha: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        draw(at: CGPoint.zero, blendMode: .normal, alpha: alpha)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
