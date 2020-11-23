//
//  ChannelViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 12/27/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation
import ReactiveSwift
import Parse
import TwilioChatClient
import TMROFutures

typealias ChannelViewControllerDelegates = ChannelDetailViewControllerDelegate & ChannelViewControllerDelegate

protocol ChannelViewControllerDelegate: class {
    func channelView(_ controller: ChannelViewController, didTapShare message: Messageable)
    func channelViewControllerDidTapContext(_ controller: ChannelViewController)
}

class ChannelViewController: FullScreenViewController, ActiveChannelAccessor {

    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    lazy var detailVC = ChannelDetailViewController(delegate: self.delegate)
    lazy var collectionView = ChannelCollectionView()
    lazy var collectionViewManager = ChannelCollectionViewManager(with: self.collectionView)
    lazy var imagePickerVC = UIImagePickerController()

    let disposables = CompositeDisposable()

    private var animateMessages: Bool = true

    var indexPathForEditing: IndexPath?

    unowned let delegate: ChannelViewControllerDelegates

    /// A Boolean value that determines whether the `MessagesCollectionView` scrolls to the
    /// last item whenever the `InputTextView` begins editing.
    ///
    /// The default value of this property is `false`.
    /// NOTE: This is related to `scrollToLastItem` whereas the below flag is related to `scrollToBottom` - check each function for differences
    var scrollsToLastItemOnKeyboardBeginsEditing: Bool = false

    /// A Boolean value that determines whether the `MessagesCollectionView` scrolls to the
    /// bottom whenever the `InputTextView` begins editing.
    ///
    /// The default value of this property is `false`.
    /// NOTE: This is related to `scrollToBottom` whereas the above flag is related to `scrollToLastItem` - check each function for differences
    var scrollsToBottomOnKeyboardBeginsEditing: Bool = true

    // A Boolean value that determines whether the `MessagesCollectionView`
    /// maintains it's current position when the height of the `MessageInputBar` changes.
    ///
    /// The default value of this property is `false`.
    var maintainPositionOnKeyboardFrameChanged: Bool = true

    var isMessagesControllerBeingDismissed: Bool = false {
        didSet {
            if self.isMessagesControllerBeingDismissed {
                self.resignFirstResponder()
            } else {
                self.becomeFirstResponder()
            }
        }
    }

    var collectionViewBottomInset: CGFloat = 0 {
        didSet {
            self.collectionView.contentInset.bottom = self.collectionViewBottomInset
            self.collectionView.verticalScrollIndicatorInsets.bottom = self.collectionViewBottomInset
        }
    }

    // Custom Input Accessory View
    lazy var messageInputAccessoryView = MessageInputAccessoryView(with: self)

    override var inputAccessoryView: UIView? {
        return self.messageInputAccessoryView
    }

    /// A CGFloat value that adds to (or, if negative, subtracts from) the automatically
    /// computed value of `messagesCollectionView.contentInset.bottom`. Meant to be used
    /// as a measure of last resort when the built-in algorithm does not produce the right
    /// value for your app. Please let us know when you end up having to use this property.
    var additionalBottomInset: CGFloat = 10 {
        didSet {
            let delta = self.additionalBottomInset - oldValue
            self.collectionViewBottomInset += delta
        }
    }

    private var isFirstLayout: Bool = true

    init(delegate: ChannelViewControllerDelegates) {
        self.delegate = delegate
        super.init()
    }

    deinit {
        self.disposables.dispose()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init?(withObject object: DeepLinkable) {
        fatalError("init(withObject:) has not been implemented")
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    // Remembers which keyboard a user uses for this conversation.
    override var textInputContextIdentifier: String? {
        return self.activeChannel?.id
    }

    override func initializeViews() {
        super.initializeViews()

        self.view.addSubview(self.blurView)
        self.view.addSubview(self.collectionView)

        self.addChild(viewController: self.detailVC, toView: self.view)

        self.collectionView.dataSource = self.collectionViewManager
        self.collectionView.delegate = self.collectionViewManager

        if let activeChannel = self.activeChannel {
            self.load(activeChannel: activeChannel)
        }

        self.addChild(self.messageInputAccessoryView.expandingTextView.attachmentInputVC)

        self.setupHandlers()
        self.subscribeToUpdates()
    }

    private func setupHandlers() {

        self.collectionViewManager.didTapShare = { [unowned self] message in
            self.delegate.channelView(self, didTapShare: message)
        }

        self.collectionViewManager.didTapResend = { [unowned self] message in
            self.resend(message: message)
        }

        self.collectionViewManager.didTapEdit = { [unowned self] message, indexPath in
            self.indexPathForEditing = indexPath
            self.messageInputAccessoryView.edit(message: message)
        }

        self.collectionView.onDoubleTap { [unowned self] (doubleTap) in
            if self.messageInputAccessoryView.expandingTextView.isFirstResponder {
                self.messageInputAccessoryView.expandingTextView.resignFirstResponder()
            }
        }

        self.disposables.add(ChannelSupplier.shared.activeChannel.producer.on(value:  { [unowned self] (channel) in
            guard let activeChannel = channel else {
                self.collectionViewManager.reset()
                return
            }
            
            self.load(activeChannel: activeChannel)
        }).start())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.isMessagesControllerBeingDismissed = false

        if MessageSupplier.shared.sections.count > 0 {
            self.collectionViewManager.set(newSections: MessageSupplier.shared.sections,
                                           animate: self.animateMessages) {
                                            self.animateMessages = false
            }
        } else {
            MessageSupplier.shared.didGetLastSections = { [unowned self] sections in
                self.collectionViewManager.set(newSections: sections,
                                               animate: self.animateMessages) {
                                                self.animateMessages = false
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.isMessagesControllerBeingDismissed = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.isMessagesControllerBeingDismissed = false
        MessageSupplier.shared.reset()
        ChannelSupplier.shared.set(activeChannel: nil)
        self.collectionViewManager.reset()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.blurView.expandToSuperviewSize()

        self.detailVC.view.size = CGSize(width: self.view.width - (Theme.contentOffset * 2), height: self.detailVC.collapsedHeight )
        self.detailVC.view.top = Theme.contentOffset
        self.detailVC.view.centerOnX()

        self.collectionView.frame = self.view.safeAreaLayoutGuide.layoutFrame

        if self.isFirstLayout {
            defer { self.isFirstLayout = false }
            self.addKeyboardObservers()
            self.collectionViewBottomInset = self.requiredInitialScrollViewBottomInset()
        }
    }
}
