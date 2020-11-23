//
//  ChannelCollectionViewManager+Typing.swift
//  Benji
//
//  Created by Benji Dodgson on 11/11/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension ChannelCollectionViewManager {

    func setTypingIndicatorViewHidden(_ isHidden: Bool, performUpdates updates: (() -> Void)? = nil) {
        self.setTypingIndicatorViewHidden(isHidden, animated: true, whilePerforming: updates) { [weak self] success in
            guard let `self` = self else { return }
            if success, self.isLastMessageVisible() == true {
                runMain {
                    self.collectionView.scrollToEnd()
                }
            }
        }
    }

    private func setTypingIndicatorViewHidden(_ isHidden: Bool,
                                              animated: Bool,
                                              whilePerforming updates: (() -> Void)? = nil,
                                              completion: ((Bool) -> Void)? = nil) {

        guard self.collectionView.isTypingIndicatorHidden != isHidden else {
            completion?(false)
            return
        }

        let section = self.collectionView.numberOfSections
        self.collectionView.channelLayout.setTypingIndicatorViewHidden(isHidden)

        if animated {
            self.collectionView.performBatchUpdates({ [weak self] in
                guard let `self` = self else { return }
                self.performUpdatesForTypingIndicatorVisability(at: section)
                updates?()
                }, completion: completion)
        } else {
            self.performUpdatesForTypingIndicatorVisability(at: section)
            updates?()
            completion?(true)
        }
    }

    /// Performs a delete or insert on the `ChannelCollectionView` on the provided section
    ///
    /// - Parameter section: The index to modify
    private func performUpdatesForTypingIndicatorVisability(at section: Int) {
        if self.collectionView.isTypingIndicatorHidden {
            self.collectionView.deleteSections([section - 1])
        } else {
            self.collectionView.insertSections([section])
        }
    }

    func isLastMessageVisible() -> Bool {
        let sectionCount = self.numberOfSections()

        guard sectionCount > 0, let sectionValue = self.sections.last else { return false }

        let lastIndexPath = IndexPath(item: sectionValue.items.count - 1, section: sectionCount - 1)
        return self.collectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }

    /// A method that by default checks if the section is the last in the
    /// `messagesCollectionView` and that `isTypingIndicatorViewHidden`
    /// is FALSE
    ///
    /// - Parameter section
    /// - Returns: A Boolean indicating if the TypingIndicator should be presented at the given section
    func isSectionReservedForTypingIndicator(_ section: Int) -> Bool {
        return !self.collectionView.isTypingIndicatorHidden
            && section == self.numberOfSections(in: self.collectionView) - 1
    }
}
