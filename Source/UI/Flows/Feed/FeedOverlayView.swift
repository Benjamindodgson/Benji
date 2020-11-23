//
//  ReadOverlayView.swift
//  Benji
//
//  Created by Benji Dodgson on 7/28/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Koloda

class FeedOverlayView: OverlayView {

    let titleLabel = DisplayLabel()

    override var overlayState: SwipeResultDirection?  {
        didSet {
            switch overlayState {
            case .left? :
                self.titleLabel.text =  "👎"
                self.backgroundColor = Color.red.color.withAlphaComponent(0.5)
            case .right? :
                self.titleLabel.text = "👍"
                self.backgroundColor = Color.blue.color.withAlphaComponent(0.5)
            default:
                break
            }

        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }

    private func initialize() {
        self.roundCorners()
        self.titleLabel.font = UIFont.systemFont(ofSize: 100)
        self.addSubview(self.titleLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.titleLabel.setSize(withWidth: self.proportionalWidth)
        self.titleLabel.centerOnXAndY()
    }
}
