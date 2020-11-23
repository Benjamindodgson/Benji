//
//  DisplayableImageView.swift
//  Benji
//
//  Created by Benji Dodgson on 2/4/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse
import SDWebImage

class DisplayableImageView: View {

    private(set) var imageView = UIImageView()

    var displayable: ImageDisplayable? {
        didSet {
            guard let displayable = self.displayable else { return }
            self.updateImageView(with: displayable)
            self.setNeedsLayout()
        }
    }

    override init() {
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        self.displayable = UIImage()
        super.init(coder: aDecoder)
    }

    override func initializeSubviews() {
        super.initializeSubviews()

        self.set(backgroundColor: .clear)
        self.addSubview(self.imageView)
        self.imageView.contentMode = .scaleAspectFill
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.imageView.frame = self.bounds
    }

    private func updateImageView(with displayable: ImageDisplayable) {
        if let photo = displayable.image {
            self.imageView.image = photo
        } else if let objectID = displayable.userObjectID {
            self.findUser(with: objectID)
        } else if let url = displayable.url {
            self.downloadAndSetImage(url: url)
        }
    }

    private func downloadAndSetImage(for user: User) {
        user.smallImage?.getDataInBackground { (imageData: Data?, error: Error?) in
            guard let data = imageData else { return }
            let image = UIImage(data: data)
            self.imageView.image = image
        }
    }

    private func findUser(with objectID: String) {
        User.localThenNetworkQuery(for: objectID)
            .observeValue(with: { (user) in
                self.downloadAndSetImage(for: user)
            })
    }

    private func downloadAndSetImage(url: URL) {
        self.imageView.sd_setImage(with: url, completed: { [weak self] (image, error, imageCacheType, imageUrl) in
            guard let `self` = self, let downloadedImage = image else { return }
            self.imageView.image = downloadedImage
        })
    }
}
