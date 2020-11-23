//
//  FeedIntroView.swift
//  Benji
//
//  Created by Benji Dodgson on 12/7/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROLocalization

class FeedIntroView: View {

    private let timeLabel = DisplayThinLabel()
    private let label = FeedQuoteLabel()
    private let descritpionLabel = SmallLabel()

    override func initializeSubviews() {
        super.initializeSubviews()

        self.addSubview(self.timeLabel)
        self.addSubview(self.label)
        self.addSubview(self.descritpionLabel)
    }

    func set(count: Int) {
        if count > 0 {
            let time = count * 20
            let text = LocalizedString(id: "", arguments: [], default: "minutes of distractions avoided today.")
            self.timeLabel.set(text: "\(time)", color: .lightPurple)
            self.label.set(text: text)
        } else {
            self.timeLabel.set(text: "😌")
            self.label.set(text: "You had a distraction free day.")
        }

        self.descritpionLabel.set(text: "Each notification is a 20 minute distraction to your brain.", color: .background3, alignment: .center)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.timeLabel.setSize(withWidth: self.width)
        self.timeLabel.centerOnX()
        self.timeLabel.bottom = self.halfHeight - 5

        self.label.setSize(withWidth: self.width * 0.9)
        self.label.centerOnX()
        self.label.top = self.halfHeight + 5

        self.descritpionLabel.setSize(withWidth: self.width)
        self.descritpionLabel.centerOnX()
        self.descritpionLabel.bottom = self.bottom
    }
}

private class FeedQuoteLabel: Label {

    func set(text: Localized) {
        let attributed = AttributedString(text,
                                          fontType: .regular,
                                          color: .white)

        self.set(attributed: attributed,
                 alignment: .center,
                 stringCasing: .unchanged)
    }
}
