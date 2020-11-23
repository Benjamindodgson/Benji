//
//  AttachentCollectionViewManager.swift
//  Benji
//
//  Created by Benji Dodgson on 8/29/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

class AttachmentCollectionViewManager: CollectionViewManager<AttachementCell> {

    var didSelectPhotoOption: CompletionOptional = nil
    var didSelectLibraryOption: CompletionOptional = nil

    override func collectionView(_ collectionView: UICollectionView,
                                 layout collectionViewLayout: UICollectionViewLayout,
                                 sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        let value = collectionView.height * 0.5 - (layout.minimumLineSpacing * 0.5)
        return CGSize(width: value, height: value)
    }

    override func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: 60, height: collectionView.height)
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        guard let cv = collectionView as? AttachmentCollectionView,
            kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }

        let header = cv.dequeueReusableHeaderView(AttachementHeaderView.self, for: indexPath)

        header.photoButton.didSelect = { [unowned self] in
            self.didSelectPhotoOption?()
        }

        header.libraryButton.didSelect = { [unowned self] in
            self.didSelectLibraryOption?()
        }

        return header
    }
}
