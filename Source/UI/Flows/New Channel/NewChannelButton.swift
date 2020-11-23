//
//  NewChannelButton.swift
//  Benji
//
//  Created by Benji Dodgson on 12/26/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class NewChannelButton: LoadingButton {

    private var xOffset: CGFloat = 0
    private var yOffset: CGFloat = 0

    func update(for contentType: NewChannelContent) {
        UIView.animate(withDuration: Theme.animationDuration,
                       animations: {
                        self.titleLabel?.alpha = 0
                        self.titleLabel?.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }) { (completed) in
            switch contentType {
            case .purpose(_):
                self.set(style: .normal(color: .purple, text: "CREATE"))
            case .favorites(_):
                self.set(style: .normal(color: .purple, text: "CREATE"))
            }

            self.layoutNow()

            UIView.animate(withDuration: Theme.animationDuration) {
                self.titleLabel?.alpha = 1
                self.titleLabel?.transform = .identity
            }
        }
    }
}
