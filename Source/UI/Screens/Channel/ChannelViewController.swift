//
//  ChannelViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 12/27/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation
import ReactiveSwift

class ChannelViewController: ViewController, ScrolledModalControllerPresentable, KeyboardObservable {

    var topMargin: CGFloat {
        guard let topInset = UIWindow.topWindow()?.safeAreaInsets.top else { return 0 }
        return topInset + 60
    }

    var scrollView: UIScrollView? {
        return self.channelCollectionVC.collectionView
    }

    var scrollingEnabled: Bool = true
    var didUpdateHeight: ((CGFloat, TimeInterval) -> ())?

    let channelType: ChannelType

    lazy var channelCollectionVC = ChannelCollectionViewController()

    private let messageInputView = MessageInputView()
    private(set) var bottomGradientView = GradientView()

    private var bottomOffset: CGFloat {
        var offset: CGFloat = 16
        if let handler = self.keyboardHandler, handler.currentKeyboardHeight == 0 {
            offset += self.view.safeAreaInsets.bottom
        }
        return offset
    }

    init(channelType: ChannelType) {
        self.channelType = channelType
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init?(withObject object: DeepLinkable) {
        fatalError("init(withObject:) has not been implemented")
    }

    override func initializeViews() {
        super.initializeViews()

        self.registerKeyboardEvents()
        self.view.set(backgroundColor: .background3)

        self.addChild(viewController: self.channelCollectionVC)
        self.view.addSubview(self.bottomGradientView)

        self.view.addSubview(self.messageInputView)
        self.messageInputView.textView.growingDelegate = self

        self.messageInputView.contextButton.onTap { [unowned self] (tap) in
            guard let text = self.messageInputView.textView.text, !text.isEmpty else { return }
            self.send(message: text)
        }

        self.channelCollectionVC.collectionView.onDoubleTap { [unowned self] (doubleTap) in
            if self.messageInputView.textView.isFirstResponder {
                self.messageInputView.textView.resignFirstResponder()
            }
        }

        self.loadMessages(for: self.channelType)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let handler = self.keyboardHandler else { return }

        self.channelCollectionVC.view.size = CGSize(width: self.view.width,
                                                    height: self.view.height - handler.currentKeyboardHeight)
        self.channelCollectionVC.view.top = 0
        self.channelCollectionVC.view.centerOnX()

        self.messageInputView.size = CGSize(width: self.view.width - 32, height: self.messageInputView.textView.currentHeight)
        self.messageInputView.centerOnX()
        self.messageInputView.bottom = self.channelCollectionVC.view.bottom - self.bottomOffset

        let gradientHeight = self.channelCollectionVC.view.height - self.messageInputView.top
        self.bottomGradientView.size = CGSize(width: self.view.width, height: gradientHeight)
        self.bottomGradientView.bottom = self.channelCollectionVC.view.bottom
        self.bottomGradientView.centerOnX()
    }

    func loadMessages(for type: ChannelType) {
        self.channelCollectionVC.loadMessages(for: type)
    }

    func sendSystem(message: String) {
        let systemMessage = SystemMessage(avatar: Lorem.avatar(),
                                          context: Lorem.context(),
                                          body: message,
                                          id: String(Lorem.randomString()),
                                          isFromCurrentUser: true,
                                          timeStampAsDate: Date())
        self.channelCollectionVC.channelDataSource.append(item: .system(systemMessage))
        self.reset()
    }

    func send(message: String) {
        guard let channel = ChannelManager.shared.selectedChannel else { return }

        ChannelManager.shared.sendMessage(to: channel, with: message)
        self.reset()
    }

    private func reset() {
        self.channelCollectionVC.collectionView.scrollToBottom()
        self.messageInputView.textView.text = String()
    }

    func handleKeyboard(height: CGFloat, with animationDuration: TimeInterval) {

        UIView.animate(withDuration: animationDuration, animations: {
            self.channelCollectionVC.collectionView.height = self.view.height - height
            self.channelCollectionVC.collectionView.collectionViewLayout.invalidateLayout()
        }) { (completed) in
            if completed {
                self.channelCollectionVC.collectionView.scrollToBottom()
            }
        }
    }
}

extension ChannelViewController: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: Theme.animationDuration) {
            self.messageInputView.textView.height = height
            self.view.layoutNow()
        }
    }
}
