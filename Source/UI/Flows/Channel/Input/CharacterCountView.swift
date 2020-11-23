//
//  CharacterCountView.swift
//  Benji
//
//  Created by Benji Dodgson on 1/24/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

class CharacterCountView: View {

    let label = SmallLabel()

    override func initializeSubviews() {
        super.initializeSubviews()

        self.addSubview(self.label)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.label.expandToSuperviewSize()
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 4
    }

    func udpate(with count: Int, max: Int) {
        if count >= max {
            self.isHidden = false
            self.label.set(text: self.getText(from: count, max: max), color: .red, alignment: .center)
        } else if count >= max - 20 {
            self.isHidden = false
            self.label.set(text: self.getText(from: count, max: max), color: .orange, alignment: .center)
        } else {
            self.isHidden = true
        }
    }

    private func getText(from count: Int, max: Int) -> String {

        return String("\(String(count))/\(String(max))")
    }
}
