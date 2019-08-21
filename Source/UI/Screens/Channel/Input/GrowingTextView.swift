//
//  GrowingTextView.swift
//  Benji
//
//  Created by Benji Dodgson on 7/2/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

protocol GrowingTextViewDelegate: UITextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat)
}

class GrowingTextView: TextView {

    override open var text: String! {
        didSet {
            self.setNeedsDisplay()
        }
    }

    var currentHeight: CGFloat = 0

    // Maximum length of text. 0 means no limit.
    var maxLength: Int = 250

    // Trim white space and newline characters when end editing. Default is true
    var trimWhiteSpaceWhenEndEditing: Bool = true

    // Customization
    var minHeight: CGFloat = 34 {
        didSet {
            self.resetLayout()
        }
    }

    var maxHeight: CGFloat = 200 {
        didSet {
            self.resetLayout()
        }
    }

    var attributedPlaceholder: NSAttributedString? {
        didSet {
            self.setNeedsDisplay()
        }
    }

    weak var growingDelegate: GrowingTextViewDelegate?

    private var shouldScrollAfterHeightChanged = true
    // Calculate and adjust textview's height
    private var oldText: String = ""
    private var oldSize: CGSize = .zero

    // Initialize
    override func initialize() {
        super.initialize()

        let styleAttributes = StringStyle(font: .regularSemiBold, color: .white).attributes
        self.typingAttributes = styleAttributes
        self.contentMode = .redraw

        self.keyboardAppearance = .dark
        self.keyboardType = .twitter

        self.tintColor = Color.white.color
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: self.minHeight)
    }

    private func resetLayout() {
        self.oldSize = .zero
        self.layoutNow()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if self.text == self.oldText && self.size == self.oldSize { return }
        self.oldText = self.text
        self.oldSize = self.size

        let size = self.sizeThatFits(CGSize(width: self.bounds.size.width, height: CGFloat.greatestFiniteMagnitude))
        var height = size.height

        // Constrain minimum height
        height = self.minHeight > 0 ? max(height, self.minHeight) : height

        // Constrain maximum height
        height = self.maxHeight > 0 ? min(height, self.maxHeight) : height

        // Update height if needed
        if height != self.currentHeight {
            self.shouldScrollAfterHeightChanged = true
            self.currentHeight = height
            self.growingDelegate?.textViewDidChangeHeight(self, height: height)
        } else if self.shouldScrollAfterHeightChanged {
            self.shouldScrollAfterHeightChanged = false
            self.scrollToCorrectPosition()
        }
    }

    private func scrollToCorrectPosition() {
        if self.isFirstResponder {
            self.scrollRangeToVisible(NSMakeRange(-1, 0)) // Scroll to bottom
        } else {
            self.scrollRangeToVisible(NSMakeRange(0, 0)) // Scroll to top
        }
    }

    // Show placeholder if needed
    override func draw(_ rect: CGRect) {
        super.draw(rect)

        if self.text.isEmpty {
            let xValue = self.textContainerInset.left + self.textContainer.lineFragmentPadding
            let yValue = self.textContainerInset.top
            let width = rect.size.width - xValue - self.textContainerInset.right
            let height = rect.size.height - yValue - self.textContainerInset.bottom
            let placeholderRect = CGRect(x: xValue, y: yValue, width: width, height: height)

            if let attributedPlaceholder = self.attributedPlaceholder {
                // Prefer to use attributedPlaceholder
                attributedPlaceholder.draw(in: placeholderRect)
            }
        }
    }

    // Trim white space and new line characters when end editing.
    override func textDidEndEditing(notification: Notification) {
        if let sender = notification.object as? GrowingTextView, sender == self {
            if self.trimWhiteSpaceWhenEndEditing {
                self.text = self.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                self.setNeedsDisplay()
            }
            self.scrollToCorrectPosition()
        }
    }

    // Limit the length of text
    override func textDidChange(notification: Notification) {
        if let sender = notification.object as? GrowingTextView, sender == self {
            if self.maxLength > 0 && self.text.count > maxLength {
                let endIndex = self.text.index(self.text.startIndex, offsetBy: maxLength)
                self.text = String(self.text[..<endIndex])
                self.undoManager?.removeAllActions()
            }
            self.setNeedsDisplay()
        }
    }
}

