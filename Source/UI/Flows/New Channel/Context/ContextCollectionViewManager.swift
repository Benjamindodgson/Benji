//
//  ContextCollectionViewManager.swift
//  Benji
//
//  Created by Benji Dodgson on 4/6/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ContextCollectionViewManager: CollectionViewManager<ContextCell> {

    override func collectionView(_ collectionView: UICollectionView,
                                 layout collectionViewLayout: UICollectionViewLayout,
                                 sizeForItemAt indexPath: IndexPath) -> CGSize {

        guard let context = self.items.value[safe: indexPath.row] else { return .zero }
        return self.getSize(for: context, collectionView: collectionView)
    }

    private func getSize(for context: ConversationContext, collectionView: UICollectionView) -> CGSize {
        let label = SmallBoldLabel()
        label.set(text: context.title)
        var size = label.getSize(withWidth: collectionView.width)
        size.width += 50
        size.height = 40
        return size
    }
}
