//
//  MessageInputTextView.swift
//  Benji
//
//  Created by Benji Dodgson on 8/30/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

class MessageInputTextView: InputTextView {

    lazy var countView = CharacterCountView()
    lazy var attachmentInputVC = AttachmentViewController(with: self.attachmentDelegate)
    var isShowingAttachments: Bool = false
    var textDidChange: ((String) -> Void)?

    private let attachmentDelegate: AttachmentViewControllerDelegate

    init(with attachmentDelegate: AttachmentViewControllerDelegate) {
        self.attachmentDelegate = attachmentDelegate
        super.init(frame: .zero, textContainer: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func initialize() {
        super.initialize()

        self.addSubview(self.countView)
        self.countView.isHidden = true
    }

    func toggleInputView() {
        defer {
            if !self.isFirstResponder {
                self.becomeFirstResponder()
            }
        }

        if self.isShowingAttachments {
            self.inputView = nil
        } else {
            self.inputView = self.attachmentInputVC.view
        }

        self.isShowingAttachments.toggle()

        self.reloadInputViews()
    }

    override func textDidChange(notification: Notification) {
        super.textDidChange(notification: notification)
        self.countView.udpate(with: self.text.count, max: self.maxLength)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.countView.size = CGSize(width: 70, height: 20)
        self.countView.right = self.width - 5
        self.countView.bottom = self.height - 5
    }
}
