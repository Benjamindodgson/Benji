//
//  MessageInputAccessoryView.swift
//  Benji
//
//  Created by Benji Dodgson on 6/2/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Lottie
import TMROLocalization

protocol MessageInputAccessoryViewDelegate: class {
    func messageInputAccessory(_ view: MessageInputAccessoryView, didUpdate message: Messageable,
                               with text: String)
    func messageInputAccessory(_ view: MessageInputAccessoryView, didSend text: String,
                               context: MessageContext,
                               attributes: [String: Any])
}

class MessageInputAccessoryView: View, ActiveChannelAccessor {

    private static let preferredHeight: CGFloat = 54.0
    private static let maxHeight: CGFloat = 200.0

    var previewAnimator: UIViewPropertyAnimator?
    var previewView: PreviewMessageView?
    var interactiveStartingPoint: CGPoint?

    var messageContext: MessageContext = .casual {
        didSet {
            self.borderColor = self.messageContext.color.color.cgColor
        }
    }

    var editableMessage: Messageable?

    var alertAnimator: UIViewPropertyAnimator?
    var selectionFeedback = UIImpactFeedbackGenerator(style: .rigid)
    var borderColor: CGColor? {
        didSet {
            self.inputContainerView.layer.borderColor = self.borderColor ?? self.messageContext.color.color.cgColor
        }
    }

    let inputContainerView = View()
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterialDark))
    let expandingTextView = InputTextView()
    let alertProgressView = AlertProgressView()
    let animationView = AnimationView(name: "loading")
    lazy var alertConfirmation = AlertConfirmationView()
    let overlayButton = UIButton()

    unowned let delegate: MessageInputAccessoryViewDelegate

    init(with delegate: MessageInputAccessoryViewDelegate) {
        self.delegate = delegate
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: MessageInputAccessoryView.preferredHeight)
    }

    override var intrinsicContentSize: CGSize {
        var newSize = self.bounds.size

        if self.expandingTextView.bounds.size.height > 0.0 {
            newSize.height = self.expandingTextView.bounds.size.height + 20.0
        }

        if newSize.height < MessageInputAccessoryView.preferredHeight || newSize.height > 120.0 {
            newSize.height = MessageInputAccessoryView.preferredHeight
        }

        if newSize.height > MessageInputAccessoryView.maxHeight {
            newSize.height = MessageInputAccessoryView.maxHeight
        }

        return newSize
    }

    override func initializeSubviews() {
        super.initializeSubviews()

        self.set(backgroundColor: .clear)

        self.messageContext = .casual

        self.addSubview(self.inputContainerView)
        self.inputContainerView.set(backgroundColor: .clear)

        self.inputContainerView.addSubview(self.blurView)

        self.inputContainerView.addSubview(self.animationView)
        self.animationView.contentMode = .scaleAspectFit
        self.animationView.loopMode = .loop

        self.inputContainerView.addSubview(self.alertProgressView)
        self.alertProgressView.set(backgroundColor: .red)
        self.alertProgressView.size = .zero

        self.inputContainerView.addSubview(self.expandingTextView)

        self.addSubview(self.overlayButton)

        self.inputContainerView.layer.masksToBounds = true
        self.inputContainerView.layer.borderWidth = Theme.borderWidth
        self.inputContainerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMinYCorner]
        self.inputContainerView.layer.cornerRadius = Theme.cornerRadius

        self.setupConstraints()
        self.setupGestures()
        self.setupHandlers()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.blurView.expandToSuperviewSize()
        self.overlayButton.expandToSuperviewSize()
        self.alertProgressView.height = self.inputContainerView.height

        self.animationView.size = CGSize(width: 18, height: 18)
        self.animationView.match(.right, to: .right, of: self.inputContainerView, offset: Theme.contentOffset)
        self.animationView.centerOnY()
    }

    // MARK: SETUP

    private func setupConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false

        let guide = layoutMarginsGuide
        self.inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        self.inputContainerView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        self.inputContainerView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -10).isActive = true
        self.inputContainerView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        self.inputContainerView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true

        self.expandingTextView.leadingAnchor.constraint(equalTo: self.inputContainerView.leadingAnchor).isActive = true
        self.expandingTextView.trailingAnchor.constraint(equalTo: self.inputContainerView.trailingAnchor).isActive = true
        self.expandingTextView.topAnchor.constraint(equalTo: self.inputContainerView.topAnchor).isActive = true
        self.expandingTextView.bottomAnchor.constraint(equalTo: self.inputContainerView.bottomAnchor).isActive = true
        self.expandingTextView.setContentHuggingPriority(.defaultHigh, for: .vertical)
    }

    private func setupGestures() {
        let panRecognizer = UIPanGestureRecognizer { [unowned self] (recognizer) in
            self.handle(pan: recognizer)
        }
        panRecognizer.delegate = self
        self.overlayButton.addGestureRecognizer(panRecognizer)

        let longPressRecognizer = UILongPressGestureRecognizer { [unowned self] (recognizer) in
            self.handle(longPress: recognizer)
        }
        longPressRecognizer.delegate = self
        self.overlayButton.addGestureRecognizer(longPressRecognizer)
    }

    private func setupHandlers() {

        self.expandingTextView.textDidChange = { [unowned self] text in
            self.handleTextChange(text)
        }

        self.overlayButton.onTap { [unowned self] (tap) in
            if !self.expandingTextView.isFirstResponder {
                self.expandingTextView.becomeFirstResponder()
            }
        }

        self.alertConfirmation.didCancel = { [unowned self] in
            self.resetAlertProgress()
        }
    }

    // MARK: HANDLERS

    private func handleTextChange(_ text: String) {
        guard let channelDisplayable = self.activeChannel,
            text.count > 0,
            case ChannelType.channel(let channel) = channelDisplayable.channelType else { return }
        // Twilio throttles this call to every 5 seconds
        channel.typing()
    }

    // MARK: PUBLIC

    func edit(message: Messageable) {
        self.editableMessage = message
        self.expandingTextView.text = localized(message.text)
        self.messageContext = message.context
        self.expandingTextView.becomeFirstResponder()
    }

    func reset() {
        self.expandingTextView.text = String()
        self.expandingTextView.alpha = 1
        //self.resetInputViews()
        self.resetAlertProgress()
        self.expandingTextView.countView.isHidden = true
    }

//    func resetInputViews() {
//        self.expandingTextView.inputAccessoryView = nil
//        self.expandingTextView.reloadInputViews()
//    }

    func resetAlertProgress() {
        self.messageContext = .casual
        self.alertProgressView.width = 0
        self.alertProgressView.set(backgroundColor: .red)
        self.alertProgressView.alpha = 1
        //self.resetInputViews()
        self.alertProgressView.layer.removeAllAnimations()
        self.borderColor = self.messageContext.color.color.cgColor
    }
}

class AlertProgressView: View {}
