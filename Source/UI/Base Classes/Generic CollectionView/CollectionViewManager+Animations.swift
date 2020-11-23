//
//  CollectionViewManager+Animations.swift
//  Benji
//
//  Created by Benji Dodgson on 2/9/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension CollectionViewManager {

    func animateOut(position: AnimationPosition,
                    concatenate: Bool,
                    completion: CompletionOptional) {

        let visibleCells = self.collectionView.visibleCells

        guard visibleCells.count > 0 else {
            self.collectionView.alpha = 0
            completion?()
            return
        }

        let duration: TimeInterval = Theme.animationDuration
        var longestDelay: TimeInterval = 0

        for (index, cell) in visibleCells.enumerated() {
            cell.alpha = 1.0
            let delay: TimeInterval = concatenate ? duration/Double(visibleCells.count)*Double(index) : 0
            UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut, animations: {
                cell.transform = position.getTransform(for: cell)
                cell.alpha = 0.0
            })
            longestDelay = delay
        }

        delay(duration + longestDelay) {
            self.collectionView.alpha = 0
            completion?()
        }
    }

    func animateIn(position: AnimationPosition,
                   concatenate: Bool,
                   scrollToEnd: Bool,
                   completion: CompletionOptional) {

        if scrollToEnd {
            self.collectionView.scrollToEnd(animated: false, completion: { [unowned self] in
                self.animateToFinal(direction: position, concatenate: concatenate, completion: completion)
            })
        } else {
            self.animateToFinal(direction: position, concatenate: concatenate, completion: completion)
        }
    }

    private func animateToFinal(direction: AnimationPosition,
                                concatenate: Bool,
                                completion: CompletionOptional) {

        let visibleCells = self.collectionView.visibleCells

        guard visibleCells.count > 0 else {
            self.collectionView.alpha = 1
            completion?()
            return
        }

        let duration: TimeInterval = Theme.animationDuration
        var longestDelay: TimeInterval = 0

        for (index, cell) in visibleCells.enumerated() {
            cell.alpha = 0.0
            cell.transform = direction.getTransform(for: cell)
            self.collectionView.alpha = 1
            let delay: TimeInterval = concatenate ? duration/Double(visibleCells.count)*Double(index) : 0
            UIView.animate(withDuration: duration, delay: delay, options: .curveEaseInOut, animations: {
                cell.transform = .identity
                cell.alpha = 1.0
            })
            longestDelay = delay
        }

        delay(duration + longestDelay) {
            completion?()
        }
    }
}
