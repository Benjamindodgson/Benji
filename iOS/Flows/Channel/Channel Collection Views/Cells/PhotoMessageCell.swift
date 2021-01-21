//
//  PhotoMessageCell.swift
//  Benji
//
//  Created by Benji Dodgson on 7/4/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TwilioChatClient
import SDWebImage

class PhotoMessageCell: BaseMessageCell {

    private let imageView = DisplayableImageView()
    private var cachedURL: URL?

    override func initializeViews() {
        super.initializeViews()

        self.contentView.insertSubview(self.imageView, belowSubview: self.avatarView)
    }

    override func configure(with message: Messageable) {
        super.configure(with: message)

        guard case MessageKind.photo(let item) = message.kind else { return }

        self.avatarView.set(avatar: message.avatar)
        if let image = item.image {
            self.imageView.displayable = image
        } else if let tchMessage = message as? TCHMessage {
            self.loadImage(from: tchMessage)
        }

        self.imageView.displayable = item.image
        self.imageView.imageView.contentMode = .scaleAspectFill
        self.imageView.imageView.clipsToBounds = true
        self.imageView.layer.cornerRadius = 5
        self.imageView.layer.masksToBounds = true 
    }

    private func loadImage(from message: TCHMessage) {
        guard message.hasMedia() else { return }

        if let url = self.cachedURL {
            self.load(url: url)
        } else {
            message.getMediaContentURL()
                .mainSink(receivedResult: { (result) in
                    switch result {
                    case .success(let urlString):
                        if let url = URL(string: urlString) {
                            self.load(url: url)
                        }
                    case .error(_):
                        break
                    }
                }).store(in: &self.cancellables)
        }
    }

    private func load(url: URL) {
        self.cachedURL = url

        SDWebImageManager.shared.loadImage(with: url,
                                           options: [],
                                           progress: { (received, expected, url) in
                                            print("RECEIVED: \(received)")
                                            print("EXPECTED: \(expected)")
                                           }, completed: { (image, data, error, cacheType, finished, url) in
                                            self.imageView.displayable = image
                                           })
    }

    override func layoutContent(with attributes: ChannelCollectionViewLayoutAttributes) {
        super.layoutContent(with: attributes)

        self.imageView.frame = attributes.attributes.imageFrame
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.cachedURL = nil
    }
}
