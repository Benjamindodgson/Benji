//
//  FeedCollectionViewManager.swift
//  Benji
//
//  Created by Benji Dodgson on 7/28/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Koloda

class FeedCollectionViewManager: NSObject {

    private let collectionView: FeedCollectionView

    private var items: [FeedType] = []

    var didComplete: (FeedType) -> Void = { _ in }

    init(with collectionView: FeedCollectionView) {
        self.collectionView = collectionView
        super.init()
        self.initialize()
    }

    private func initialize() {
        self.collectionView.countOfVisibleCards = 3
        self.collectionView.backgroundCardsTopMargin = 10
        self.collectionView.alphaValueOpaque = 1.0
        self.collectionView.alphaValueTransparent = 1.0
    }

    func set(items: [FeedType]) {
        self.items = items
        self.collectionView.reloadData()
    }
}

extension FeedCollectionViewManager: KolodaViewDataSource {

    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return self.items.count
    }

    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .slow
    }

    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        guard let item = self.items[safe: index] else { return UIView() }
        
        let feedView = FeedView()
        feedView.configure(with: item)

        feedView.didComplete = {
            koloda.swipe(.right)
            self.didComplete(item)
        }
        return feedView
    }
}

extension FeedCollectionViewManager: KolodaViewDelegate {

    func koloda(_ koloda: KolodaView, allowedDirectionsForIndex index: Int) -> [SwipeResultDirection] {
        return [.left, .right]
    }

    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {}

    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) { }

    func kolodaShouldApplyAppearAnimation(_ koloda: KolodaView) -> Bool {
        return true
    }

    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {

    }

    func koloda(_ koloda: KolodaView, didShowCardAt index: Int) {}

    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return nil
    }

    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return false
    }
}
