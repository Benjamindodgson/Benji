//
//  MessageContextButton.swift
//  Benji
//
//  Created by Benji Dodgson on 7/2/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ContextButton: View {

    private let contextCircleTop = ContextCircleView()
    private let contextCircleLeft = ContextCircleView()
    private let contextCircleRight = ContextCircleView()
    private let contextCircleCenter = ContextCircleView()
    private let contextCircleBottom = ContextCircleView()

    override func initialize() {
        
        self.addSubview(self.contextCircleTop)
        self.addSubview(self.contextCircleBottom)
        self.addSubview(self.contextCircleLeft)
        self.addSubview(self.contextCircleRight)
        self.addSubview(self.contextCircleCenter)

        self.set(backgroundColor: .clear)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let circleSize = CGSize(width: 4, height: 4)
        let circleOffset: CGFloat = 4

        self.contextCircleCenter.size = circleSize
        self.contextCircleCenter.centerOnXAndY()

        self.contextCircleTop.size = circleSize
        self.contextCircleTop.bottom = self.contextCircleCenter.top - circleOffset
        self.contextCircleTop.centerOnX()

        self.contextCircleBottom.size = circleSize
        self.contextCircleBottom.top = self.contextCircleCenter.bottom + circleOffset
        self.contextCircleBottom.centerOnX()

        self.contextCircleRight.size = circleSize
        self.contextCircleRight.left = self.contextCircleCenter.right + circleOffset
        self.contextCircleRight.centerOnY()

        self.contextCircleLeft.size = circleSize
        self.contextCircleLeft.right = self.contextCircleCenter.left - circleOffset
        self.contextCircleLeft.centerOnY()
    }
}

private class ContextCircleView: View {

    override func initialize() {
        self.set(backgroundColor: .white)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.makeRound()
    }
}
