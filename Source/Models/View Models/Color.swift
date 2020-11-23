//
//  Color.swift
//  Benji
//
//  Created by Benji Dodgson on 12/25/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

enum Color: String, CaseIterable {

    case background1
    case background2
    case background3
    case background4
    case backgroundWithAlpha
    case blue
    case purple
    case lightPurple
    case teal
    case orange
    case green
    case red
    case white
    case clear
    case keyboardBackground

    var color: UIColor {
        switch self {
        case .background1:
            return UIColor(named: "Background1")!
        case .background2:
            return UIColor(named: "Background2")!
        case .background3:
            return UIColor(named: "Background3")!
        case .background4:
            return UIColor(named: "Background4")!
        case .backgroundWithAlpha:
            return UIColor(named: "BackgroundWithAlpha")!
        case .blue:
            return UIColor(named: "Blue")!
        case .purple:
            return UIColor(named: "Purple")!
        case .lightPurple:
            return UIColor(named: "LightPurple")!
        case .red:
            return UIColor(named: "Red")!
        case .teal:
            return UIColor(named: "Teal")!
        case .green:
            return UIColor(named: "Green")!
        case .white:
            return UIColor(named: "White")!
        case .clear:
            return UIColor(named: "Clear")!
        case .orange:
            return UIColor(named: "Orange")!
        case .keyboardBackground:
            return UIColor(named: "Keyboard")!
        }
    }
}
