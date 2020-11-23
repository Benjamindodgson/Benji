//
//  NSAttributedString+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 12/25/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension Array where Element: NSAttributedString {
    var concatenated: NSAttributedString {
        let joined = self.reduce(NSMutableAttributedString(), +)
        return NSAttributedString(joined)
    }
}

extension Array where Element: NSMutableAttributedString {
    var concatenated: NSMutableAttributedString {
        return reduce(NSMutableAttributedString(), +)
    }
}

extension NSAttributedString {

    @objc convenience init(_ mutableAttributedString: NSMutableAttributedString) {
        self.init(attributedString: mutableAttributedString)
    }

    static func +(lhs: NSAttributedString, rhs: NSAttributedString) -> NSMutableAttributedString {
        let mutableLHS = NSMutableAttributedString(lhs)
        mutableLHS.append(rhs)
        return mutableLHS
    }

    func height(considering width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect,
                                       options: [.usesLineFragmentOrigin, .usesFontLeading],
                                       context: nil)

        return boundingBox.height.rounded(FloatingPointRoundingRule.up)
    }

    func width(considering height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect,
                                       options: [.usesLineFragmentOrigin,
                                                 .usesFontLeading], context: nil)

        return boundingBox.width.rounded(FloatingPointRoundingRule.up)
    }

    func getSize(withWidth width: CGFloat) -> CGSize {

        let attributes = self.attributes(at: 0,
                                         longestEffectiveRange: nil,
                                         in: NSRange(location: 0, length: self.length))
        
        let maxSize = CGSize(width: width, height: CGFloat.infinity)

        let size: CGSize = self.string.boundingRect(with: maxSize,
                                                    options: .usesLineFragmentOrigin,
                                                    attributes: attributes,
                                                    context: nil).size
        return size
    }

    var existingAttributes: [NSAttributedString.Key : Any]? {
        return self.attributes(at: 0, effectiveRange: nil)
    }
}

