//
//  MessagePreviewViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 1/22/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

class MessagePreviewViewController: ViewController {

    let message: Messageable
    let messageTextView = MessageTextView()
    let channelAttributes: ChannelCollectionViewLayoutAttributes
    let bubbleView = View()

    init(with message: Messageable,
         attributes: ChannelCollectionViewLayoutAttributes) {

        self.message = message
        self.channelAttributes = attributes
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = self.bubbleView
    }

    override var preferredContentSize: CGSize {
        get {
            return self.channelAttributes.attributes.bubbleViewFrame.size
        }
        set {
            self.preferredContentSize = .zero 
        }
    }

    override func initializeViews() {
        super.initializeViews()
        
        self.view.addSubview(self.messageTextView)
        if case MessageKind.text(let text) = self.message.kind {
            self.messageTextView.set(text: text, messageContext: self.message.context)
        }
        self.messageTextView.size = self.channelAttributes.attributes.textViewFrame.size

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.messageTextView.centerOnXAndY()
    }
}
