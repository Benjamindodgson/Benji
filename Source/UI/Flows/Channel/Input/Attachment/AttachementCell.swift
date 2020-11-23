//
//  AttachementCell.swift
//  Benji
//
//  Created by Benji Dodgson on 8/29/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Photos

struct Attachement: ManageableCellItem, Hashable {

    var id: String {
        return self.asset.localIdentifier
    }

    var displayble: ImageDisplayable {
        return UIImage()
    }

    var asset: PHAsset

    init(with asset: PHAsset) {
        self.asset = asset
    }

    static func == (lhs: Attachement, rhs: Attachement) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

class AttachementCell: UICollectionViewCell, ManageableCell {
    typealias ItemType = Attachement

    private let imageView = DisplayableImageView()
    private let imageManager = PHImageManager()
    private let selectedView = View()

    var onLongPress: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initializeViews() {
        self.contentView.addSubview(self.imageView)
        self.imageView.imageView.contentMode = .scaleToFill
        self.imageView.clipsToBounds = true

        self.contentView.addSubview(self.selectedView)
        self.selectedView.backgroundColor = Color.lightPurple.color.withAlphaComponent(0.5)
        self.selectedView.alpha = 0
    }

    func configure(with item: Attachement?) {
        guard let attachement = item else { return }

        self.loadImage(for: attachement)
    }

    func collectionViewManagerWillDisplay() {}
    func collectionViewManagerDidEndDisplaying() {}

    override func layoutSubviews() {
        super.layoutSubviews()

        self.imageView.expandToSuperviewSize()
        self.selectedView.expandToSuperviewSize()
    }

    func update(isSelected: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.selectedView.alpha = isSelected ? 1.0 : 0.0
        }
    }

    func loadImage(for attachment: Attachement) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        self.imageManager.requestImage(for: attachment.asset,
                                       targetSize: self.size,
                                       contentMode: .aspectFill,
                                       options: options) { [unowned self] (image, info) in
                                        if let img = image {
                                            self.imageView.displayable = img
                                        }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.imageView.displayable = nil
    }
}
