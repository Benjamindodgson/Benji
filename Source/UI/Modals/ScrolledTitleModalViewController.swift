//
//  ScrolledTitleModalViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 8/17/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ScrolledTitleModalViewController<TitlePresentable: ScrolledModalControllerPresentable>: ScrolledModalViewController<TitlePresentable> {

    private let titleLabel = Display2Label()
    private let titleContainer = View()

    var titleText: Localized? {
        didSet {
            guard let text = self.titleText else { return }
            self.titleLabel.set(text: text, alignment: .center)
        }
    }

    override func initializeViews() {
        super.initializeViews()

        self.view.addSubview(self.titleContainer)
        self.titleContainer.addSubview(self.titleLabel)
        self.titleContainer.set(backgroundColor: .background3)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.titleContainer.width = self.modalContainerView.width

        if let attributedText = self.titleLabel.attributedText {
            let titleWidth = self.titleContainer.width - 24 * 2
            self.titleLabel.size = attributedText.getSize(withWidth: titleWidth)
            self.titleContainer.height = self.titleLabel.height + 32 + Theme.contentOffset
        } else {
            self.titleContainer.height = 0
        }

        self.titleLabel.top = 32
        self.titleLabel.left = 24

        self.titleContainer.bottom = self.modalContainerView.top
        self.titleContainer.centerOnX()
        self.titleContainer.round(corners: UIRectCorner(arrayLiteral: [.topLeft, .topRight]), size: CGSize(width: Theme.cornerRadius, height: Theme.cornerRadius))
    }

}
