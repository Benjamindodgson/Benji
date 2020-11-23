//
//  TextInputAccessoryView.swift
//  Benji
//
//  Created by Benji Dodgson on 12/27/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROLocalization

class TextInputAccessoryView: View {

    private let label = SmallLabel()
    private let cancelButton = CancelButton()
    private var blurView = UIVisualEffectView(effect: nil)

    var textColor: Color = .white {
        didSet {
            guard let text = self.text else { return }
            self.label.set(text: text,
                           color: self.textColor,
                           alignment: .left,
                           stringCasing: .unchanged)
        }
    }

    var text: Localized? {
        didSet {
            let old = oldValue ?? ""
            guard let text = self.text, localized(text) != localized(old) else { return }
            UIView.animate(withDuration: Theme.animationDuration,
                           delay: Theme.animationDuration,
                           options: [],
                           animations: {
                            self.label.alpha = 0
                            self.label.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { (completed) in

                if completed {
                    self.label.set(text: text, color: self.textColor, alignment: .left, stringCasing: .unchanged)
                    self.layoutNow()

                    UIView.animate(withDuration: Theme.animationDuration) {
                        self.label.alpha = 1
                        self.label.transform = .identity
                    }
                }
            }
        }
    }

    var keyboardAppearance: UIKeyboardAppearance? {
        didSet {
            if let appearance = self.keyboardAppearance, appearance == .light {
                self.blurView.effect = nil
            } else {
                self.blurView.effect = UIBlurEffect(style: .dark)
            }
            self.set(backgroundColor: .keyboardBackground)
        }
    }

    var didCancel: CompletionOptional = nil

    override func initializeSubviews() {
        super.initializeSubviews()

        self.set(backgroundColor: .keyboardBackground)

        self.addSubview(self.blurView)
        self.addSubview(self.label)
        self.addSubview(self.cancelButton)
        self.cancelButton.didSelect = { [unowned self] in
            self.didCancel?()
        }

        self.label.alpha = 0
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.blurView.expandToSuperviewSize()

        self.cancelButton.size = CGSize(width: 44, height: 44)
        self.cancelButton.centerOnY()
        self.cancelButton.right = self.width - Theme.contentOffset

        let maxWidth = self.width - (Theme.contentOffset * 3) - 44
        self.label.setSize(withWidth: maxWidth)
        self.label.left = Theme.contentOffset
        self.label.top = 8
    }
}
