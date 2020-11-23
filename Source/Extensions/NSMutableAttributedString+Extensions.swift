//
//  NSMutableAttributedString+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 12/27/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {

    convenience init(_ attributedString: NSAttributedString) {
        self.init(attributedString: attributedString)
    }

    convenience init(_ string: String, with attributes: [NSAttributedString.Key: Any]) {
        self.init(string: string)
        self.addAttributes(attributes, range: NSMakeRange(0, string.count))
    }

    static func +(lhs: NSMutableAttributedString,
                  rhs: NSMutableAttributedString) -> NSMutableAttributedString {
        // Make a copy so we don't modify the original string
        let lhsCopy = NSMutableAttributedString(lhs)
        lhsCopy.append(rhs)
        return lhsCopy
    }

    func addAttribute(_ name: NSAttributedString.Key, value: Any) {
        self.addAttribute(name, value: value, range: NSMakeRange(0, self.length))
    }

    func addAttributes(_ attrs: [NSAttributedString.Key : Any]) {
        self.addAttributes(attrs, range: NSMakeRange(0, self.length))
    }

    func addAttribute(_ attributeKey: NSAttributedString.Key, toSubstring substring: String) {
        if let range = self.string.range(of: substring) {
            self.addAttribute(attributeKey, value: substring, range: range.nsRange(self.string))
        }
    }

    func removeAttributes(atRange range: NSRange) {
        var mutableRange = range
        if range.location + range.length <= self.length {
            let attributes = self.attributes(at: range.location, effectiveRange: &mutableRange)
            for attribute in attributes {
                self.removeAttribute(attribute.key, range: range)
            }
        } else {
            print("INVALID RANGE FOR: \(self.string)")
        }
    }

    func height(forConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            context: nil)
        return ceil(boundingBox.height)
    }

    func width(forConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            context: nil)
        return ceil(boundingBox.width)
    }

    func linkItems() {

        // Find all substrings with a [<Link>](<Value>) structure
        // NOTE: Because value is technically a link, it can not have a space or it will cause a crash
        guard let regex = try? NSRegularExpression(pattern: "(\\[(.+?)\\]\\((.+?)\\))",
                                                   options: .caseInsensitive) else { return }
        let nsString = self.string as NSString
        let matchRanges = regex.matches(in: self.string,
                                        range: NSRange(location: 0, length: nsString.length))

        var rangesToDelete: [NSRange] = []
        matchRanges.forEach { (match) in

            guard let value = self.string.substring(with: match.range) else { return }

            let labelPattern = "\\[.+?\\]"
            if let labelRange = value.range(of: labelPattern,
                                            options: .regularExpression,
                                            range: nil,
                                            locale: nil) {

                let finalRange = NSRange(location: match.range.location + 1,
                                         length: labelRange.nsRange(self.string).length - 1)

                let openBracketRange = NSRange(location: match.range.location, length: 1)
                rangesToDelete.append(openBracketRange)
                let closedBrackedRange = NSRange(location: match.range.location
                    + (labelRange.nsRange(self.string).length - 1),
                                                 length: 1)
                rangesToDelete.append(closedBrackedRange)

                var linkValue: String? = nil
                let valuePattern = "\\(.+?\\)"
                if let valueRange = value.range(of: valuePattern,
                                                options: .regularExpression,
                                                range: nil,
                                                locale: nil) {

                    var link = String(value[valueRange])
                    link = link.replacingOccurrences(of: "(", with: "")
                    link = link.replacingOccurrences(of: ")", with: "")
                    linkValue = link

                    rangesToDelete.append(valueRange.nsRange(self.string))
                }

                if let link = linkValue {
                    self.addAttribute(.link, value: link, range: finalRange)
                }
            }
        }

        for range in rangesToDelete.reversed() {
            self.mutableString.replaceCharacters(in: range, with: "")
        }
    }
}
