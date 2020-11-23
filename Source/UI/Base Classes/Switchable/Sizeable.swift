//
//  Sizeable.swift
//  Benji
//
//  Created by Benji Dodgson on 1/16/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

protocol Sizeable: class {
    func getHeight(for width: CGFloat) -> CGFloat
    func getWidth(for height: CGFloat) -> CGFloat
}

extension Sizeable {

    func getHeight(for width: CGFloat) -> CGFloat {
        return .zero
    }

    func getWidth(for height: CGFloat) -> CGFloat {
        return .zero 
    }
}
