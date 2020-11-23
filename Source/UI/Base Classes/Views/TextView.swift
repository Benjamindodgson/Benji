//
//  TextView.swift
//  Benji
//
//  Created by Benji Dodgson on 12/25/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROLocalization

class TextView: UITextView {

    // Maximum length of text. 0 means no limit.
    var maxLength: Int = 250

    // Trim white space and newline characters when end editing. Default is true
    var trimWhiteSpaceWhenEndEditing: Bool = true

    override var text: String! {
        didSet {
            self.setNeedsDisplay()
        }
    }

    private var attributedPlaceholder: NSAttributedString? {
        didSet {
            self.setNeedsDisplay()
        }
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.initialize()
    }

    convenience init() {
        self.init(frame: CGRect.zero, textContainer: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(frame: .zero, textContainer: nil)
        self.initialize()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func initialize() {

        let styleAttributes = StringStyle(font: .smallBold, color: .white).attributes
        self.typingAttributes = styleAttributes
        self.contentMode = .redraw

        self.keyboardAppearance = .dark
        
        self.set(backgroundColor: .clear)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidChange),
                                               name: UITextView.textDidChangeNotification,
                                               object: self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidEndEditing),
                                               name: UITextView.textDidEndEditingNotification,
                                               object: self)
    }

    func set(placeholder: Localized, color: Color = .background4) {
        let styleAttributes = StringStyle(font: .smallBold, color: color).attributes
        let string = NSAttributedString(string: localized(placeholder), attributes: styleAttributes)
        self.attributedPlaceholder = string
    }

    func set(attributed: AttributedString,
             alignment: NSTextAlignment = .left,
             lineCount: Int = 0,
             lineBreakMode: NSLineBreakMode = .byWordWrapping,
             stringCasing: StringCasing = .unchanged,
             isEditable: Bool = false,
             linkColor: Color = .white) {

        let string = stringCasing.format(string: attributed.string.string)
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttributes(attributed.attributes, range: NSRange(location: 0,
                                                                             length: attributedString.length))

        attributedString.linkItems()
        self.linkTextAttributes = [.foregroundColor: linkColor.color, .underlineStyle: 0]

        self.isEditable = isEditable
        self.attributedText = attributedString
        self.textContainer.maximumNumberOfLines = lineCount
        self.textContainer.lineBreakMode = lineBreakMode
        self.textAlignment = alignment
        self.isUserInteractionEnabled = true
        self.dataDetectorTypes = .all
        self.textContainerInset = .zero
        self.textContainer.lineFragmentPadding = 0
    }

    // Trim white space and new line characters when end editing.
    @objc func textDidEndEditing(notification: Notification) {
        if let sender = notification.object as? TextView, sender == self {
            if self.trimWhiteSpaceWhenEndEditing {
                self.text = self.text?.trimmingCharacters(in: .whitespacesAndNewlines)
                self.setNeedsDisplay()
            }
            self.scrollToCorrectPosition()
        }
    }

    // Limit the length of text
    @objc func textDidChange(notification: Notification) {
        if let sender = notification.object as? TextView, sender == self {
            if self.maxLength > 0 && self.text.count > self.maxLength {
                let endIndex = self.text.index(self.text.startIndex, offsetBy: self.maxLength)
                self.text = String(self.text[..<endIndex])
                self.undoManager?.removeAllActions()
            }
            self.setNeedsDisplay()
        }
    }

    func scrollToCorrectPosition() {
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

    func setSize(withWidth width: CGFloat) {
        self.size = self.getSize(withWidth: width)
    }

    func getSize(withWidth width: CGFloat) -> CGSize {
        guard let t = self.text, !t.isEmpty, let attText = self.attributedText else { return CGSize.zero }

        let attributes = attText.attributes(at: 0,
                                            longestEffectiveRange: nil,
                                            in: NSRange(location: 0, length: attText.length))

        let maxSize = CGSize(width: width, height: CGFloat.infinity)

        let size: CGSize = t.boundingRect(with: maxSize,
                                          options: .usesLineFragmentOrigin,
                                          attributes: attributes,
                                          context: nil).size

        return size
    }

    /// Adds the provided attributes to all the text in the view.
    func addTextAttributes(_ attributes: [NSAttributedString.Key : Any]) {
        guard let current = self.attributedText else { return }

        let newString = NSMutableAttributedString(current)
        let range = NSMakeRange(0, newString.string.count)
        newString.addAttributes(attributes, range: range)
        self.attributedText = newString
    }
}
