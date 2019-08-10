//
//  CollectionViewManager.swift
//  Benji
//
//  Created by Benji Dodgson on 12/27/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation
import ReactiveSwift
import GestureRecognizerClosures

class CollectionViewManager<CellType: DisplayableCell & UICollectionViewCell>: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var collectionView: UICollectionView

    var items = MutableProperty<[CellType.ItemType]>([])

    var didSelect: (_ item: CellType.ItemType, _ indexPath: IndexPath) -> Void = { _, _ in }
    var didLongPress: (_ item: CellType.ItemType, _ indexPath: IndexPath) -> Void = { _, _ in }

    required init(with collectionView: UICollectionView) {

        self.collectionView = collectionView
        super.init()
        self.initialize()
    }

    func initialize() {
        self.collectionView.register(CellType.self, forCellWithReuseIdentifier: CellType.reuseID)
    }

    func reset() {
        self.items.value = []
        self.collectionView.reloadData()
    }

    func set(newItems: [CellType.ItemType]) {
        self.updateCollectionView(items: newItems, modify: { [weak self] in
            guard let `self` = self else { return }
            self.items.value = newItems
        })
    }

    func append(item: CellType.ItemType, in section: Int = 0) {

        guard self.items.value.count > 0 else {
            self.set(newItems: [item])
            return
        }

        guard !self.items.value.contains(item) else { return }

        let indexPath = IndexPath(item: self.items.value.count, section: section)
        self.items.value.append(item)
        self.collectionView.insertItems(at: [indexPath])
    }

    func update(item: CellType.ItemType, in section: Int = 0) {
        var indexPath: IndexPath?
        for (index, existingItem) in self.items.value.enumerated() {
            if existingItem == item {
                indexPath = IndexPath(item: index, section: section)
                break
            }
        }

        guard let ip = indexPath else { return }

        self.items.value[ip.item] = item
        self.collectionView.reloadItems(at: [ip])
    }

    func delete(item: CellType.ItemType, in section: Int = 0) {

        var indexPath: IndexPath?
        for (index, existingItem) in self.items.value.enumerated() {
            if existingItem == item {
                indexPath = IndexPath(item: index, section: section)
                break
            }
        }

        guard let ip = indexPath else { return }

        self.items.value.remove(at: ip.item)
        self.collectionView.deleteItems(at: [ip])
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.backgroundView?.isHidden = self.items.value.count > 0
        return self.items.value.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell: CellType = collectionView.dequeueReusableCell(withReuseIdentifier: CellType.reuseID,
                                                                for: indexPath) as! CellType

        let item = self.items.value[safe: indexPath.row]
        cell.configure(with: item)
        //Reset all gestures
        cell.contentView.gestureRecognizers?.forEach({ (recognizer) in
            cell.contentView.removeGestureRecognizer(recognizer)
        })

        cell.contentView.onTap { [weak self] (tap) in
            guard let `self` = self, let item = self.items.value[safe: indexPath.row] else { return }
            self.didSelect(item, indexPath)
        }

        cell.contentView.onLongPress { [weak self] (longPress) in
            guard let `self` = self, let item = self.items.value[safe: indexPath.row] else { return }
            self.didLongPress(item, indexPath)
        }

        return self.managerWillDisplay(cell: cell, for: indexPath)
    }

    func managerWillDisplay(cell: CellType, for indexPath: IndexPath) -> CellType {
        return cell
    }

    private func updateCollectionView(items: [CellType.ItemType], modify: @escaping () -> Void) {

        self.reloadCollectionView(previousItems: self.items.value,
                                  newItems: items,
                                  modify: modify)
    }

    private func reloadCollectionView(previousItems: [CellType.ItemType],
                                      newItems: [CellType.ItemType],
                                      modify: @escaping () -> Void) {

        self.collectionView.reload(previousItems: previousItems,
                                   newItems: newItems,
                                   equalityOption: .equality,
                                   modify: modify,
                                   completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.width, height: 100)
    }
}
