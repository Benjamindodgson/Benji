//
//  PreviewMessageView.swift
//  Benji
//
//  Created by Benji Dodgson on 8/24/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation


class PreviewMessageView: View {

    let minHeight: CGFloat = 52
    let textView = InputTextView()
    let backgroundView = View()

    override func initializeSubviews() {
        super.initializeSubviews()

        self.addSubview(self.backgroundView)
        self.addSubview(self.textView)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = Theme.cornerRadius
        self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner]
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.backgroundView.frame = self.bounds

        self.textView.size = CGSize(width: self.width, height: self.height)
        self.textView.left = 0
        self.textView.top = 0
    }
}
