//
//  KeyboardManagable.swift
//  Benji
//
//  Created by Benji Dodgson on 8/11/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

protocol KeyboardObservable: NSObjectProtocol {
    func handleKeyboard(height: CGFloat, with animationDuration: TimeInterval)
}

private var keyboardHandlerKey: UInt8 = 0
extension KeyboardObservable where Self: ViewController {

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

    unowned let vc: ViewController & KeyboardObservable

    private(set) var currentKeyboardHeight: CGFloat = 0

    init(with vc: ViewController & KeyboardObservable) {
        self.vc = vc
        super.init()
    }

    @objc func keyboardWillHandle(notification: Notification) {
        guard let size = notification.keyboardSize,
            let animationDuration = notification.keyboardAnimationDuration else { return }

        var newHeight: CGFloat = 0
        switch notification.name {
        case UIResponder.keyboardWillShowNotification:
            newHeight = size.height
        case UIResponder.keyboardWillHideNotification:
            newHeight = 0
        default:
            break
        }

        self.currentKeyboardHeight = newHeight
        self.vc.handleKeyboard(height: newHeight, with: animationDuration)
    }
}

extension Notification {

    var keyboardSize: CGSize? {
        return (self.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
    }
    var keyboardAnimationDuration: Double? {
        return self.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
    }
}
