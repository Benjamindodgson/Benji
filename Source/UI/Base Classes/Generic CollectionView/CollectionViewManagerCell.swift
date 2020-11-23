//
//  CollectionViewManagerCell.swift
//  Benji
//
//  Created by Benji Dodgson on 12/28/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

// A base class that other cells managed by a CollectionViewManager can inherit from.
class CollectionViewManagerCell: UICollectionViewCell {

    var onLongPress: (() -> Void)?

    override init(frame: CGRect) {

        super.init(frame: frame)
        self.initializeLongPressGesture()
        self.initializeSubviews()
    }

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
        self.initializeLongPressGesture()
        self.initializeSubviews()
    }

    func initializeSubviews() { }

    private func initializeLongPressGesture() {

        let longPress = UILongPressGestureRecognizer { [unowned self] (longPress) in
            switch longPress.state {
            case .possible, .changed:
                break
            case .began:
                self.onLongPress?()
                // If the user starts a long press, we don't want this cell to be selected.
                // Cancelling touches in this view means only a long press event will occur.
                longPress.cancelsTouchesInView = true
            case .ended, .cancelled, .failed:
                longPress.cancelsTouchesInView = false
            @unknown default:
                break
            }
        }
        // Don't cancel other touches so we don't interfere with the default cell selection behavior
        longPress.cancelsTouchesInView = false
        self.contentView.addGestureRecognizer(longPress)
    }

    func collectionViewManagerWillDisplay() { }
    func collectionViewManagerDidEndDisplaying() { }
}
