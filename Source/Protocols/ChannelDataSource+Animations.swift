//
//  ChannelDataSource+Animations.swift
//  Benji
//
//  Created by Benji Dodgson on 2/9/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension ChannelDataSource {

    func animateIn(completion: CompletionOptional) {
        self.collectionView.scrollToEnd(animated: false) { [unowned self] in
            self.animateAfterScroll(with: completion)
        }
    }

    private func animateAfterScroll(with completion: CompletionOptional) {
        let visibleCells = self.collectionView.visibleCells

        guard visibleCells.count > 0 else {
            /// If no cells are visible make sure to show the collection view. Otherwise no new messages will be visible
            self.collectionView.alpha = 1
            completion?()
            return
        }

        let duration: TimeInterval = 0.3
        var longestDelay: TimeInterval = 0

        for (index, cell) in visibleCells.enumerated() {
            let animationDelay: TimeInterval = duration/Double(visibleCells.count)*Double(index)
            
            if let messageCell = cell as? MessageCell, let message = messageCell.currentMessage {
                /// Set the initial transform and alpha for cells
                cell.alpha = 0.0
                let direction: AnimationPosition = message.isFromCurrentUser ? .right : .left
                cell.transform = direction.getTransform(for: cell)
                /// Reveal the collection view once cells are hidden.
                self.collectionView.alpha = 1

                UIView.animate(withDuration: duration, delay: animationDelay, options: .curveEaseInOut, animations: {
                    /// Animate cells now that collection view is showing
                    cell.transform = .identity
                    cell.alpha = 1.0
                })
            }
            longestDelay = animationDelay
        }

        /// Set all Headers and Footers to hidden
        for header in self.collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader) {
            header.alpha = 0
        }

        for footer in self.collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionFooter) {
            footer.alpha = 0
        }

        /// Reveal all Headers and Footers
        UIView.animate(withDuration: duration) {
            for header in self.collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader) {
                header.alpha = 1
            }
            
            for footer in self.collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionFooter) {
                footer.alpha = 1
            }
        }

        delay(longestDelay + duration) {
            completion?()
        }
    }
}
