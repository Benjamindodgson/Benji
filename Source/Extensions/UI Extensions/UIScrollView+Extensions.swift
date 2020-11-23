//
//  UIScrollView+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 1/8/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension UIScrollView {

    var currentXIndex: Int {
        let width = self.width
        guard width > 0 else { return 0 }
        return Int((self.contentOffset.x + (0.5 * width)) / width)
    }

    var currentYIndex: Int {
        let height = self.height
        guard height > 0 else { return 0 }
        return Int((self.contentOffset.y + (0.5 * height)) / height)
    }

    // Scroll to a specific view so that it's top is at the top our scrollview
    func scrollVerticallyTo(view: UIView, animated: Bool) {
        if let origin = view.superview {
            // Get the Y position of your child view
            let childStartPoint = origin.convert(view.frame.origin, to: self)
            // Scroll to a rectangle starting at the Y of your subview, with a height of the scrollview
            self.scrollRectToVisible(CGRect(x: 0, y: childStartPoint.y, width: 1, height: self.frame.height), animated: animated)
        }
    }

    func scrollHorizontallyTo(view: UIView, animated: Bool) {
        if let origin = view.superview {
            // Get the x position of your child view
            let childStartPoint = origin.convert(view.frame.origin, to: self)
            // Scroll to a rectangle starting at the x of your subview, with a height of the scrollview
            self.scrollRectToVisible(CGRect(x: childStartPoint.x,
                                            y: 0,
                                            width: self.frame.width,
                                            height: 1), animated: animated)
        }
    }
}
