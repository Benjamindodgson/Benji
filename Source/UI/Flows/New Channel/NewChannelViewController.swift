//
//  ChannelPurposeViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 9/8/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse
import TMROFutures
import TMROLocalization
import ReactiveSwift

protocol NewChannelViewControllerDelegate: class {
    func newChannelViewControllerDidCreateChannel(_ controller: NewChannelViewController)
}

enum NewChannelContent: Switchable {
    case purpose(PurposeViewController)
    case favorites(ConnectionsViewController)

    var viewController: UIViewController & Sizeable {
        switch self {
        case .purpose(let vc):
            return vc
        case .favorites(let vc):
            return vc
        }
    }

    var shouldShowBackButton: Bool {
        switch self {
        case .purpose(_):
            return true
        case .favorites(_):
            return false
        }
    }
}

class NewChannelViewController: SwitchableContentViewController<NewChannelContent> {

    lazy var purposeVC = PurposeViewController()
    lazy var favoritesVC = ConnectionsViewController()

    let button = NewChannelButton()

    unowned let delegate: NewChannelViewControllerDelegate

    init(delegate: NewChannelViewControllerDelegate) {
        self.delegate = delegate
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

        self.view.addSubview(self.button)
        self.button.didSelect = { [unowned self] in
            self.buttonTapped()
        }

        self.purposeVC.textFieldDidBegin = { [unowned self] in
            UIView.animate(withDuration: Theme.animationDuration) {
                self.titleLabel.alpha = 0.2
                self.descriptionLabel.alpha = 0.2
                self.lineView.alpha = 0.2

                if let text = self.purposeVC.textField.text, !text.isEmpty {
                    self.purposeVC.contextVC.view.alpha = 0.2
                } else {
                    self.purposeVC.contextVC.view.alpha = 0
                }
            }
        }

        self.purposeVC.textFieldDidEnd = { [unowned self] in
            UIView.animate(withDuration: Theme.animationDuration) {
                self.titleLabel.alpha = 1
                self.descriptionLabel.alpha = 1
                self.lineView.alpha = 1

                if let text = self.purposeVC.textField.text, !text.isEmpty {
                    self.purposeVC.contextVC.view.alpha = 1
                } else {
                    self.purposeVC.contextVC.view.alpha = 0
                }
            }

            if let text = self.purposeVC.textField.text, !text.isEmpty {
                self.purposeVC.contextVC.collectionViewManager.select(indexPath: IndexPath(item: 0, section: 0))
            }
        }

        self.purposeVC.contextVC.collectionViewManager.onSelectedItem.signal.observeValues { [unowned self] (selectedItem) in
            guard let selectedItem = selectedItem else { return }

            self.purposeVC.textField.updateColor(for: selectedItem.item)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.button.setSize(with: self.view.width)
        self.button.centerOnX()
        self.button.bottom = self.view.height - self.view.safeAreaInsets.bottom - 10

        guard let handler = self.keyboardHandler, handler.currentKeyboardHeight > 0 else { return }

        let diff = self.view.height - handler.currentKeyboardHeight
        if diff < self.scrollView.contentSize.height {
            let offset = (self.view.height - self.scrollView.contentSize.height) * -1
            if offset > 0 {
                self.scrollView.setContentOffset(CGPoint(x: 0, y: offset), animated: false)
            }
        }
    }

    override func getInitialContent() -> NewChannelContent {
        return .favorites(self.favoritesVC)
    }

    override func getTitle() -> Localized {
        switch self.currentContent.value {
        case .purpose(_):
            return "ADD CONTEXT"
        case .favorites(_):
            return LocalizedString(id: "", default: "ADD PEOPLE")
        }
    }

    override func getDescription() -> Localized {
        switch self.currentContent.value {
        case .purpose(_):
            return "Add a name and some context to help frame the conversation."
        case .favorites(_):
            return "Add people to the converstion."
        }
    }

    override func didSelectBackButton() {
        self.currentContent.value = .favorites(self.favoritesVC)
    }

    override func willUpdateContent() {
        self.button.update(for: self.currentContent.value)
        self.view.bringSubviewToFront(self.button)
    }

    func buttonTapped() {

        let users = self.favoritesVC.collectionViewManager.selectedItems.compactMap { (orbItem) -> User? in
            return orbItem.to
        }

        let members = users.compactMap { (user) -> String? in
            return user.id
        }

        ChannelSupplier.shared.createChannel(friendlyName: "", context: .casual, members: members)
        self.delegate.newChannelViewControllerDidCreateChannel(self)
    }
}

