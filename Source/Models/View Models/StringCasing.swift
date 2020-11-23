//
//  StringCasing.swift
//  Benji
//
//  Created by Benji Dodgson on 12/27/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

enum StringCasing {
    case unchanged
    case uppercase
    case lowercase
    case capitalized

    func format(string: String) -> String {
        switch self {
        case .unchanged:
            return string
        case .uppercase:
            return string.uppercased()
        case .lowercase:
            return string.lowercased()
        case .capitalized:
            return string.capitalized
        }
    }
}

extension UILabel {

    func fade(toText text: String, layoutReady: CompletionOptional) {
        // Move our fade out code from earlier
        UIView.animate(withDuration: Theme.animationDuration, delay: 0.0, options: .curveEaseOut, animations: {
            self.alpha = 0.0
        }, completion: { finished in

            if finished {
                //Once the label is completely invisible, set the text and fade it back in
                self.attributedText = NSAttributedString(string: text, attributes: self.attributedText?.existingAttributes)
                layoutReady?()

                // Fade in
                UIView.animate(withDuration: Theme.animationDuration, delay: 0.0, options: .curveEaseIn, animations: {
                    self.alpha = 1.0
                }, completion: nil)
            }
        })
    }
}
