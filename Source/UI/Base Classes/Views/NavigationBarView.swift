//
//  NavigationBarView.swift
//  Benji
//
//  Created by Benji Dodgson on 8/10/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class NavigationBarView: View {

    static let margin: CGFloat = 14

    private(set) var titleLabel = DisplayThinLabel()

    let leftContainer = UIView()
    private(set) var leftItem: UIView?
    private var leftTapHandler: (() -> Void)?

    let rightContainer = UIView()
    private(set) var rightItem: UIView?
    private var rightTapHandler: (() -> Void)?

    override func initializeSubviews() {
        super.initializeSubviews()
        
        self.set(backgroundColor: .clear)

        self.addSubview(self.titleLabel)

        self.addSubview(self.leftContainer)
        self.leftContainer.onTap { [unowned self] (tapRecognizer) in
            guard self.leftItem != nil else { return }
            self.leftTapHandler?()
        }

        self.addSubview(self.rightContainer)
        self.rightContainer.onTap { [unowned self] (tapRecognizer) in
            guard self.rightItem != nil else { return }
            self.rightTapHandler?()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.leftContainer.left = NavigationBarView.margin
        self.leftContainer.size = CGSize(width: 30, height: 30)
        self.leftContainer.centerOnY()

        self.leftItem?.frame = self.leftContainer.bounds
        self.leftItem?.contentMode = .center

        self.rightContainer.size = CGSize(width: 30, height: 30)
        self.rightContainer.right = self.width - NavigationBarView.margin
        self.rightContainer.centerOnY()

        self.rightItem?.frame = self.rightContainer.bounds
        self.rightItem?.contentMode = .center

        if self.leftItem == nil && self.rightItem == nil {
            // If there are no left or right items, give more space for the title
            self.titleLabel.width = self.width - 2 * NavigationBarView.margin
        } else {
            // Otherwise, fill the space between the item containers with the title label
            self.titleLabel.width = self.rightContainer.left - self.leftContainer.right
        }
        self.titleLabel.height = self.height
        self.titleLabel.centerOnXAndY()
    }


    func setLeft(_ item: UIView?, tapHandler: @escaping () -> Void) {
        self.leftItem?.removeFromSuperview()

        self.leftItem = item
        if let leftItem = self.leftItem {
            self.leftContainer.addSubview(leftItem)
        }

        self.leftTapHandler = tapHandler

        self.setNeedsLayout()
    }

    func setRight(_ item: UIView, tapHandler: @escaping () -> Void) {
        self.rightItem?.removeFromSuperview()

        self.rightItem = item
        if let rightItem = self.rightItem {
            self.rightContainer.addSubview(rightItem)
        }

        self.rightTapHandler = tapHandler

        self.setNeedsLayout()
    }
}

