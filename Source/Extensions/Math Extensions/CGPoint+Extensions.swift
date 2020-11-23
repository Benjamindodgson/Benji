//
//  CGPoint+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 6/30/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension CGPoint {

    func distanceTo(_ point: CGPoint) -> CGFloat {
        return sqrt(pow(point.x - self.x, 2) + pow(point.y - self.y, 2))
    }

    func normalizedDistanceForSize(_ size: CGSize) -> CGPoint {
        // multiplies by 2 because coordinate system is (-1,1)
        let x = 2 * (self.x / size.width)
        let y = 2 * (self.y / size.height)
        return CGPoint(x: x, y: y)
    }

    func scalarProjectionPointWith(_ point: CGPoint) -> CGPoint {
        let r = self.scalarProjectionWith(point) / point.modulo
        return CGPoint(x: point.x * r, y: point.y * r)
    }

    func scalarProjectionWith(_ point: CGPoint) -> CGFloat {
        return self.dotProductWith(point) / point.modulo
    }

    func dotProductWith(_ point: CGPoint) -> CGFloat {
        return (self.x * point.x) + (self.y * point.y)
    }

    var modulo: CGFloat {
        return sqrt(self.x*self.x + self.y*self.y)
    }

    func screenPointForSize(_ screenSize: CGSize) -> CGPoint {
        let x = 0.5 * (1 + self.x) * screenSize.width
        let y = 0.5 * (1 + self.y) * screenSize.height
        return CGPoint(x: x, y: y)
    }

    func floored() -> CGPoint {
        return CGPoint(x: floor(x), y: floor(y))
    }

    mutating func flooredInPlace() {
        self = self.floored()
    }
}

extension CGPoint {
  var cgSize: CGSize {
    return CGSize(width: x, height: y)
  }

  func absolutePoint(in rect: CGRect) -> CGPoint {
    return CGPoint(x: x * rect.size.width, y: y * rect.size.height) + rect.origin
  }
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (left: CGPoint, right: CGFloat) -> CGPoint {
  return CGPoint(x: left.x * right, y: left.y * right)
}
