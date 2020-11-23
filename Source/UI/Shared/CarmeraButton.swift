//
//  CarmeraButton.swift
//  Benji
//
//  Created by Benji Dodgson on 10/12/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class CameraButton: View {

    private let darkCircle = View()
    private let innerCircle = View()
    private let selectionFeedback = UIImpactFeedbackGenerator(style: .light)

    override func initializeSubviews() {
        super.initializeSubviews()

        self.addSubview(self.darkCircle)
        self.addSubview(self.innerCircle)

        self.set(backgroundColor: .white)
        self.innerCircle.set(backgroundColor: .white)
        self.darkCircle.set(backgroundColor: .background1)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.darkCircle.size = CGSize(width: self.width - 6, height: self.height - 6)
        self.darkCircle.centerOnXAndY()
        self.darkCircle.makeRound()

        self.innerCircle.size = CGSize(width: self.width - 12, height: self.height - 12)
        self.innerCircle.centerOnXAndY()
        self.innerCircle.makeRound()

        self.makeRound()
    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.selectionFeedback.impactOccurred()
        self.innerCircle.scaleDown()
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.innerCircle.scaleUp()
    }

    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.innerCircle.scaleUp()
    }
}
