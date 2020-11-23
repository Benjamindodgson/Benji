//
//  HomeAddButton.swift
//  Benji
//
//  Created by Benji Dodgson on 6/29/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ImageViewButton: View {

    let imageView = UIImageView()
    private let selectionFeedback = UIImpactFeedbackGenerator(style: .light)
    var didSelect: CompletionOptional = nil
    var shouldScale: Bool = false

    override func initializeSubviews() {
        super.initializeSubviews()
        
        self.addSubview(self.imageView)
        self.imageView.tintColor = Color.white.color
        self.imageView.contentMode = .scaleAspectFit

        self.onTap { [unowned self] (tap) in
            self.selectionFeedback.impactOccurred()
            self.didSelect?()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.makeRound()

        self.imageView.size = CGSize(width: self.width * 0.55, height: self.height * 0.55)
        self.imageView.centerOnXAndY()
    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard self.shouldScale else { return }

        if let touch = touches.first, let view = touch.view {
            view.scaleDown()
        }
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard self.shouldScale else { return }

        if let touch = touches.first, let view = touch.view {
            view.scaleUp()
        }
    }

    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        guard self.shouldScale else { return }
        
        if let touch = touches.first, let view = touch.view {
            view.scaleUp()
        }
    }
}
