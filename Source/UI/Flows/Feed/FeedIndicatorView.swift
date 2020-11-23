//
//  FeedIndicatorView.swift
//  Benji
//
//  Created by Benji Dodgson on 2/19/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

class FeedIndicatorView: View {

    private let offset: CGFloat = 10
    private var elements: [View] = []
    private var indicator = View()

    override func initializeSubviews() {
        super.initializeSubviews()

        self.clipsToBounds = false
    }

    func configure(with count: Int) {

        self.removeAllSubviews()
        self.elements = []

        guard count > 0 else { return }
        
        for _ in 1...count {
            let element = View()
            element.set(backgroundColor: .background2)
            self.elements.append(element)
            self.addSubview(element)
        }

        self.addSubview(self.indicator)
        self.indicator.alpha = 0
        self.indicator.set(backgroundColor: .teal)

        self.layoutNow()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard self.elements.count > 0 else { return }

        var totalOffsets = self.offset * CGFloat(self.elements.count - 1)
        totalOffsets = clamp(totalOffsets, min: self.offset)
        var itemWidth = (self.width - totalOffsets) / CGFloat(self.elements.count)
        itemWidth = clamp(itemWidth, min: 1)
        
        let itemSize = CGSize(width: itemWidth, height: self.height)

        self.indicator.size = itemSize
        self.indicator.showShadow(withOffset: 2, color: Color.teal.color)
        self.indicator.centerOnY()
        self.indicator.makeRound()

        for (index, element) in self.elements.enumerated() {
            let offset = CGFloat(index) * (itemSize.width + self.offset)
            element.size = itemSize
            element.left =  offset
            element.centerOnY()
            element.makeRound()
        }
    }

    func update(to index: Int) {
        guard let element = self.elements[safe: index] else { return }

        UIView.animate(withDuration: Theme.animationDuration,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: {
                        self.indicator.alpha = 1
                        self.indicator.centerX = element.centerX
        }, completion: nil)
    }
}
