//
//  FeedRoutineView.swift
//  Benji
//
//  Created by Benji Dodgson on 12/7/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class FeedRoutineView: View {

    let textView = FeedTextView()
    let button = Button()
    var didSelect: () -> Void = {}

    override func initializeSubviews() {
        super.initializeSubviews()

        self.addSubview(self.textView)
        self.addSubview(self.button)
        self.textView.set(localizedText: "Set a time each day to check your Daily Feed.")
        self.button.set(style: .rounded(color: .blue, text: "SET"))
        self.button.onTap { [unowned self] (tap) in
            self.didSelect()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.textView.setSize(withWidth: self.width)
        self.textView.bottom = self.centerY - 10
        self.textView.centerOnX()

        self.button.size = CGSize(width: 100, height: 40)
        self.button.centerOnX()
        self.button.bottom = self.height - Theme.contentOffset
        self.button.roundCorners()
    }
}
