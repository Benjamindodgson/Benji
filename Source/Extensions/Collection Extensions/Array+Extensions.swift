//
//  Array+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 12/25/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension Array {
    func random() -> Element {
        return self[Int(arc4random_uniform(UInt32(self.count)))]
    }

    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }

    func equals<OtherSequence>(_ other: OtherSequence?,
                               areEqual: (Element, Element) -> Bool) -> Bool
        where OtherSequence: Sequence {

            guard let otherArray = other as? [Element] else { return false }
            guard self.count == otherArray.count else { return false }

            for i in 0..<self.count {
                if !areEqual(self[i], otherArray[i]) {
                    return false
                }
            }

            return true
    }
}

extension Array where Element: Equatable {

    // Remove first collection element that is equal to the given object
    mutating func remove(object: Element) {
        if let index = self.firstIndex(of: object) {
            self.remove(at: index)
        }
    }

    func find(_ object: Element) -> Element? {
        if let index = self.firstIndex(of: object) {
            return self[index]
        } else {
            return nil
        }
    }

    func all(test: (Element) -> Bool) -> Bool {
        for element in self {
            if !test(element) {
                return false
            }
        }

        return true
    }

    func elementAtRemainder(forIndex selectedIndex: Int) -> Element? {

        guard !self.isEmpty else {
            return nil
        }

        var finalIndex: Int
        if selectedIndex >= self.endIndex {
            let rem = selectedIndex % self.endIndex
            finalIndex = rem
        } else {
            finalIndex = selectedIndex
        }

        let value = self[finalIndex]
        return value
    }
}

extension Array where Element: Hashable {

    mutating func removeDuplicates() {

        var uniqueElements = Set<Element>()
        var newArray: [Element] = []

        for element in self {
            if !uniqueElements.contains(element) {
                newArray.append(element)
                uniqueElements.insert(element)
            }
        }

        self = newArray
    }
}

extension Array where Element: UIView {

    mutating func append(_ newElement: Element, toSuperview superview: UIView) {
        self.append(newElement)

        superview.addSubview(newElement)
    }

    mutating func removeAllFromSuperview(andRemoveAll removeAll: Bool) {
        for view in self {
            view.removeFromSuperview()
        }

        if removeAll {
            self.removeAll()
        }
    }
}
