//
//  String+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 12/25/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation
import PhoneNumberKit

extension String {

    init(optional value: String?) {
        if let strongValue = value {
            self.init(stringLiteral: strongValue)
        } else {
            self.init()
        }
    }
    
    func height(withConstrainedWidth width: CGFloat, fontType: FontType) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font : fontType.font], context: nil)

        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, fontType: FontType) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font : fontType.font], context: nil)

        return ceil(boundingBox.width)
    }

    // Gets an NSAttributedString compatible ranges for all the emojis in a string
    // NSAttributedStrings are encoded using UTF16, and emojis may consist of multiple code units
    // https://developer.apple.com/swift/blog/?id=30
    func getEmojiRanges() -> [NSRange] {

        var ranges: [NSRange] = []

        for (index, character) in self.enumerated() {
            guard character.isEmoji else { continue }
            let characterIndex = self.index(self.startIndex, offsetBy: index)
            let nsRange = NSRange(characterIndex...characterIndex, in: self)
            ranges.append(nsRange)
        }

        return ranges
    }

    func substring(with nsrange: NSRange) -> Substring? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return self[range]
    }

    func extraWhitespaceRemoved() -> String {
        return components(separatedBy: CharacterSet.whitespaces)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
            .trimWhitespace()
    }

    func trimWhitespace() -> String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func isValidPhoneNumber() -> Bool {
        let phoneNumberKit = PhoneKit.shared
        let partialFormatter = PhoneKit.formatter

        do {
            let _ = try phoneNumberKit.parse(self, withRegion: partialFormatter.currentRegion)
            return true
        } catch {
            return false
        }
    }

    func formatPhoneNumber() -> String? {
        guard self.isValidPhoneNumber() else { return nil }
        let number = self.filter("0123456789".contains)
        return number
    }
}

extension Range where Bound == String.Index {
    func nsRange(_ string: String) -> NSRange {
        return NSRange(location: self.lowerBound.utf16Offset(in: string),
                       length: self.upperBound.utf16Offset(in: string) - self.lowerBound.utf16Offset(in: string))
    }
}

extension String: Localized {

    var identifier: String {
        return String()
    }

    var arguments: [Localized] {
        return []
    }

    var defaultString: String? {
        return self
    }

    func localized(withArguments arguments: [Localized]) -> Localized {
        return self
    }
}
