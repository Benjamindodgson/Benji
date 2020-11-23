//
//  UIScreen+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 12/25/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension UIScreen {
    static var currentSize: ScreenSize {
        return ScreenSize.current
    }

    private static var cachedDistance: CGFloat?

    var diagonalDistance: CGFloat {
        if let distance = UIScreen.cachedDistance {
            return distance
        }

        let width: CGFloat = self.bounds.width
        let height: CGFloat = self.bounds.height
        let diagonal = sqrt(width * width + height * height)
        UIScreen.cachedDistance = diagonal
        return diagonal
    }

    func isEqualTo(screenSize: ScreenSize) -> Bool {
        return Int(self.diagonalDistance) == screenSize.rawValue
    }

    func isSmallerThan(screenSize: ScreenSize) -> Bool {
        return Int(self.diagonalDistance) < screenSize.rawValue
    }

    func isLargerThan(screenSize: ScreenSize) -> Bool {
        return Int(self.diagonalDistance) > screenSize.rawValue
    }

    func isLargerThanOrEqualTo(screenSize: ScreenSize) -> Bool {
        return Int(self.diagonalDistance) >= screenSize.rawValue
    }
}
