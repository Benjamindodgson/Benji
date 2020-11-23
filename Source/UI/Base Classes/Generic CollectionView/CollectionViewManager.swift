//  Copyright © 2019 Tomorrow Ideas Inc. All rights reserved.

import Foundation
import ReactiveSwift

class CollectionViewManager<CellType: ManageableCell & UICollectionViewCell>: NSObject,
UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    unowned let collectionView: CollectionView

    let items = MutableProperty<[CellType.ItemType]>([])

    var allowMultipleSelection: Bool = false

    private(set) var oldSelectedIndexPaths: Set<IndexPath> = []
    private(set) var selectedIndexPaths: Set<IndexPath> = [] {
        didSet {
            self.oldSelectedIndexPaths = oldValue
        }
    }

    var selectedItems: [CellType.ItemType] {
        var items: [CellType.ItemType] = []
        for indexPath in self.selectedIndexPaths {
            if let item = self.items.value[safe: indexPath.row] {
                items.append(item)
            }
        }
        return items
    }

    // MARK: Events

    lazy var onSelectedItem = Property(self._onSelectedItem)
    private let _onSelectedItem = MutableProperty<(item: CellType.ItemType, indexPath: IndexPath)?>(nil)
    var didLongPress: ((CellType.ItemType, IndexPath) -> Void)?
    var willDisplayCell: ((CellType.ItemType, IndexPath) -> Void)?
    var didFinishCenteringOnCell: ((CellType.ItemType, IndexPath) -> Void)?

    required init(with collectionView: CollectionView) {
        self.collectionView = collectionView

        super.init()

        self.initializeCollectionView()
    }

    func initializeCollectionView() {
        self.collectionView.register(CellType.self, forCellWithReuseIdentifier: CellType.reuseID)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }

    // MARK: Data Source Updating

    func set(newItems: [CellType.ItemType],
             animationCycle: AnimationCycle? = nil ,
             completion: ((Bool) -> Swift.Void)? = nil) {

        if let cycle = animationCycle {
            self.animateOut(position: cycle.outToPosition, concatenate: cycle.shouldConcatenate) { [unowned self] in
                self.updateCollectionView(items: newItems, modify: { [weak self] in
                    guard let `self` = self else { return }
                    self.items.value = newItems
                }) { (completed) in
                    self.animateIn(position: cycle.inFromPosition,
                                   concatenate: cycle.shouldConcatenate,
                                   scrollToEnd: cycle.scrollToEnd) {
                        completion?(completed)
                    }
                }
            }
        } else {
            self.updateCollectionView(items: newItems, modify: { [weak self] in
                guard let `self` = self else { return }
                self.items.value = newItems
            }) { (completed) in
                completion?(completed)
            }
        }
    }

    func set(newItems: [CellType.ItemType], completion: ((Bool) -> Swift.Void)? = nil) {
        self.updateCollectionView(items: newItems, modify: { [weak self] in
            guard let `self` = self else { return }
            self.items.value = newItems
        }, completion: completion)
    }

    private func updateCollectionView(items: [CellType.ItemType],
                                      modify: @escaping () -> Void,
                                      completion: ((Bool) -> Swift.Void)? = nil) {
        self.collectionView.reloadWithModify(previousItems: self.items.value,
                                             newItems: items,
                                             equalityOption: .equality,
                                             modify: modify,
                                             completion: completion)
    }

    func append(item: CellType.ItemType, in section: Int = 0) {
        guard !self.items.value.contains(item) else { return }

        let indexPath = IndexPath(item: self.items.value.count, section: section)
        self.items.value.append(item)
        self.collectionView.insertItems(at: [indexPath])
    }

    func insert(item: CellType.ItemType, at index: Int) {
        guard !self.items.value.contains(item) else { return }
        
        self.items.value.insert(item, at: index)
        self.collectionView.insertItems(at: [IndexPath(item: index, section: 0)])
    }

    func update(item: CellType.ItemType, in section: Int = 0) {

        guard let itemIndex = self.items.value.firstIndex(where: { (oldItem) in
            return oldItem.diffIdentifier().isEqual(item.diffIdentifier())
        }) else { return }

        self.items.value[itemIndex] = item
        self.collectionView.reloadItems(at: [IndexPath(row: itemIndex, section: section)])
    }

    func set(item: CellType.ItemType, at index: Int) {
        self.items.value[index] = item
        self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
    }

    func delete(item: CellType.ItemType, in section: Int = 0) {

        guard let itemIndex = self.items.value.firstIndex(where: { (oldItem) in
            return oldItem.diffIdentifier().isEqual(item.diffIdentifier())
        }) else { return }

        self.items.value.remove(at: itemIndex)
        self.collectionView.deleteItems(at: [IndexPath(row: itemIndex, section: section)])
    }

    func select(indexPath: IndexPath) {
        guard let item = self.items.value[safe: indexPath.row] else { return }

        if self.selectedIndexPaths.contains(indexPath) {
            self.selectedIndexPaths.remove(indexPath)
        } else if self.allowMultipleSelection {
            self.selectedIndexPaths.insert(indexPath)
        } else {
            self.selectedIndexPaths = [indexPath]
        }

        self.willScrollToSelected(indexPath: indexPath)

        self._onSelectedItem.value = (item, indexPath)

        self.updateSelected(indexPaths: self.selectedIndexPaths, and: self.oldSelectedIndexPaths)
    }

    private func updateSelected(indexPaths: Set<IndexPath>, and oldIndexPaths: Set<IndexPath>) {
        // Reset all the old indexPaths if they are not also in the new array
        oldIndexPaths.forEach { (indexPath) in
            if let cell = self.collectionView.cellForItem(at: indexPath) as? CellType {
                if !indexPaths.contains(indexPath) {
                    cell.update(isSelected: false)
                } else {
                    cell.update(isSelected: true)
                }
            }
        }

        indexPaths.forEach { (indexPath) in
            if let cell = self.collectionView.cellForItem(at: indexPath) as? CellType {
                cell.update(isSelected: true)
            }
        }
    }

    func willScrollToSelected(indexPath: IndexPath) {}

    func reset() {
        self.selectedIndexPaths = []
        self.items.value = []
        self.collectionView.reloadData()
    }

    // MARK: CollectionView Data Source

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.value.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell: CellType = collectionView.dequeueReusableCell(withReuseIdentifier: CellType.reuseID,
                                                                for: indexPath) as! CellType

        let item = self.items.value[safe: indexPath.row]
        cell.configure(with: item)

        cell.onLongPress = { [unowned self] in
            guard let item = self.items.value[safe: indexPath.row] else { return }
            self.didLongPress?(item, indexPath)
        }

        // Allows subclasses to do additional cell configuration
        self.managerDidConfigure(cell: cell, for: indexPath)

        return cell
    }

    // Subclasses can override this to do more cell configuration
    func managerDidConfigure(cell: CellType, for indexPath: IndexPath) {
        cell.update(isSelected: self.selectedIndexPaths.contains(indexPath))
    }

    // MARK: CollectionView Delegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.select(indexPath: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {

        let configurableCell: CellType = cell as! CellType
        configurableCell.collectionViewManagerWillDisplay()

        guard let item = self.items.value[safe: indexPath.row] else { return }
        self.willDisplayCell?(item, indexPath)
    }

    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let configurableCell: CellType = cell as! CellType
        configurableCell.collectionViewManagerDidEndDisplaying()
    }

    // MARK: CollectionView Flow Layout Delegate

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        return layout.itemSize
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero 
    }

    // MARK: CollectionView Menu

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return nil 
    }

    // MARK: ScrollView Delegate (These are part of the collectionview delegate)

    func scrollViewDidScroll(_ scrollView: UIScrollView) { }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let indexPath = self.collectionView.centerMostIndexPath(),
            let item = self.items.value[safe: indexPath.row] else { return }
        self.didFinishCenteringOnCell?(item, indexPath)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard let indexPath = self.collectionView.centerMostIndexPath(),
            let item = self.items.value[safe: indexPath.row] else { return }
        self.didFinishCenteringOnCell?(item, indexPath)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) { }
}

