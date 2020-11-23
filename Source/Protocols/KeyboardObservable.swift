//
//  KeyboardManagable.swift
//  Benji
//
//  Created by Benji Dodgson on 8/11/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

protocol KeyboardObservable: NSObjectProtocol {
    func handleKeyboard(frame: CGRect, with animationDuration: TimeInterval, timingCurve: UIView.AnimationCurve)
}

private var keyboardHandlerKey: UInt8 = 0
extension KeyboardObservable where Self: NSObject {

    private(set) var keyboardHandler: KeyboardHandler? {
        get {
            return self.getAssociatedObject(&keyboardHandlerKey)
        }
        set {
            self.setAssociatedObject(key: &keyboardHandlerKey, value: newValue)
        }
    }

    func registerKeyboardEvents() {
        // Disable when the keyboard is shown
        let handler = KeyboardHandler(with: self)
        self.keyboardHandler = handler

        NotificationCenter.default.addObserver(handler,
                                               selector: #selector(handler.keyboardWillHandle),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(handler,
                                               selector: #selector(handler.keyboardWillHandle),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
}

class KeyboardHandler: NSObject {

    unowned let owner: NSObject & KeyboardObservable

    private(set) var currentKeyboardHeight: CGFloat = 0 {
        didSet {
            self.previousKeyboardHeight = oldValue
        }
    }

    private(set) var previousKeyboardHeight: CGFloat?

    init(with owner: NSObject & KeyboardObservable) {
        self.owner = owner
        super.init()
    }

    @objc func keyboardWillHandle(notification: Notification) {
        guard let frame = notification.keyboardFrame,
            let animationDuration = notification.keyboardAnimationDuration,
            let number = notification.timingCurve,
            let timingCurve = UIView.AnimationCurve(rawValue: Int(truncating: number)) else { return }

        var newHeight: CGFloat = 0
        switch notification.name {
        case UIResponder.keyboardWillShowNotification:
            newHeight = frame.size.height
        case UIResponder.keyboardWillHideNotification:
            newHeight = 0
        default:
            break
        }

        self.currentKeyboardHeight = newHeight
        self.owner.handleKeyboard(frame: frame, with: animationDuration, timingCurve: timingCurve)
    }
}

extension Notification {

    var keyboardFrame: CGRect? {
        return (self.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
    }

    var keyboardAnimationDuration: Double? {
        return self.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
    }

    var timingCurve: NSNumber? {
        return self.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
    }
}
