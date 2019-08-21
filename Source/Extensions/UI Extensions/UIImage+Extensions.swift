//
//  UIImage+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 2/4/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse

extension UIImage {
    static func imageWithColor(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()

        context!.setFillColor(color.cgColor)
        context!.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }
}

extension UIImage: ImageDisplayable {

    var user: PFUser? {
        return nil
    }

    var photo: UIImage? {
        return self
    }

    var userObjectID: String? {
        return nil
    }
}

extension UIImage: Avatar {
    
    var initials: String {
        return String()
    }

    var firstName: String {
        return String()
    }

    var lastName: String {
        return String()
    }

    var handle: String {
        return String()
    }
}
