//
//  ChannelViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 12/27/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation
import ReactiveSwift

class ChannelViewController: FullScreenViewController {

    let channelType: ChannelType

    lazy var channelCollectionVC = ChannelCollectionViewController()

    lazy var inputTextView: InputTextView = {
        let textView = InputTextView()
        textView.delegate = self
        return textView
    }()

    private(set) var contextButton = ContextButton()
    private(set) var bottomGradientView = GradientView()
    let detailBar = ChannelDetailBar()

    var oldTextViewHeight: CGFloat = 48
    let bottomOffset: CGFloat = 16

    let showAnimator = UIViewPropertyAnimator(duration: 0.1,
                                              curve: .linear,
                                              animations: nil)
    let dismissAnimator = UIViewPropertyAnimator(duration: 0.1,
                                                 curve: .easeIn,
                                                 animations: nil)

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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.set(backgroundColor: .background1)

        self.addChild(viewController: self.channelCollectionVC, toView: self.contentContainer)
        self.contentContainer.addSubview(self.bottomGradientView)

        self.contentContainer.addSubview(self.inputTextView)
        self.inputTextView.growingDelegate = self

        self.contentContainer.addSubview(self.contextButton)
        self.contextButton.onTap { [unowned self] (tap) in
            guard let text = self.inputTextView.text, !text.isEmpty else { return }
           // self.sendSystem(message: text)
            self.send(message: text)
        }

        self.contentContainer.addSubview(self.detailBar)
        self.detailBar.closeButton.onTap { [unowned self] (tap) in
            self.dismiss(animated: true, completion: nil)
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)

        self.channelCollectionVC.collectionView.onDoubleTap { [unowned self] (doubleTap) in
            if self.inputTextView.isFirstResponder {
                self.inputTextView.resignFirstResponder()
            }
        }

        self.loadMessages(for: self.channelType)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.contentContainer.height = self.view.height
        self.contentContainer.top = 0

        self.detailBar.size = CGSize(width: self.contentContainer.width, height: 60)
        self.detailBar.top = self.view.safeAreaInsets.top
        self.detailBar.centerOnX()

        self.channelCollectionVC.view.frame = self.contentContainer.bounds

        self.contextButton.size = CGSize(width: 48, height: 48)
        self.contextButton.left = 16
        self.contextButton.bottom = self.contentContainer.height - self.view.safeAreaInsets.bottom

        let textViewWidth = self.contentContainer.width - self.contextButton.right - 12 - 16
        self.inputTextView.size = CGSize(width: textViewWidth, height: self.inputTextView.currentHeight)
        self.inputTextView.left = self.contextButton.right + 12
        self.inputTextView.bottom = self.contextButton.bottom

        let gradientHeight = self.contentContainer.height - self.contextButton.top 
        self.bottomGradientView.size = CGSize(width: self.contentContainer.width, height: gradientHeight)
        self.bottomGradientView.bottom = self.contentContainer.height
        self.bottomGradientView.centerOnX()
    }

    func loadMessages(for type: ChannelType) {
        switch type {
        case .system(let message):
            self.detailBar.set(avatar: message.avatar)
        case .channel(let channel):
            if let name = channel.friendlyName {
                self.detailBar.set(text: name)
            }
        }
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
        self.inputTextView.text = String()
    }
}

extension ChannelViewController: GrowingTextViewDelegate {
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: Theme.animationDuration) {
            self.inputTextView.height = height
            self.inputTextView.bottom = self.contextButton.bottom
            self.oldTextViewHeight = height
        }
    }
}
