//
//  TextField.swift
//  Benji
//
//  Created by Benji Dodgson on 12/31/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Lottie

class TextField: UITextField {

    let animationView = AnimationView(name: "loading")
    var padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

    override var text: String? {
        get {
            return super.text
        }
        set {
            guard super.text != newValue else { return }
            if let newText = newValue {
                super.text = newText
            } else {
                super.text = newValue
            }
            self.onTextChanged?()
        }
    }

    var onTextChanged: (() -> ())?
    var onEditingEnded: (() -> ())?

    init() {
        super.init(frame: .zero)
        self.initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initialize() {
        self.keyboardAppearance = .dark
 
        self.addTarget(self,
                       action: #selector(handleTextChanged),
                       for: UIControl.Event.editingChanged)
        self.addTarget(self,
                       action: #selector(handleEditingEnded),
                       for: [.editingDidEnd, .editingDidEndOnExit])

        self.addSubview(self.animationView)
        self.animationView.contentMode = .scaleAspectFit
        self.animationView.loopMode = .loop
    }

    @objc private func handleTextChanged() {
        self.onTextChanged?()
    }

    @objc private func handleEditingEnded() {
        self.onEditingEnded?()
    }

    func set(attributed: AttributedString, alignment: NSTextAlignment = .left) {
        //APPLE BUG: Trying to set both the attributed text AND the defaultAttributes will cause a memory crash
        self.text = attributed.string.string
        self.setDefaultAttributes(style: attributed.style, alignment: alignment)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.animationView.size = CGSize(width: 18, height: 18)
        self.animationView.pin(.right, padding: self.padding.right)
        self.animationView.centerOnY()
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: self.padding)
    }
}
