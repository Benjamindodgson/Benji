//
//  CenterViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 12/27/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Contacts
import Parse

enum HomeContentType: Int {
    case feed
    case list
}

class HomeViewController: FullScreenViewController {

    lazy var channelsVC = ChannelsViewController()
    lazy var feedVC = FeedViewController()
    lazy var segmentControl = HomeSegmentControl(items: ["FEED", "LIST"])
    lazy var avatarView: AvatarView = {
        let avatarView = AvatarView()
        avatarView.set(avatar: Lorem.avatar())
        return avatarView
    }()

    let headerContainer = View()
    let searchImageView = UIImageView(image: #imageLiteral(resourceName: "Search"))
    let addButton = HomeAddButton()

    private var currentType: HomeContentType = .feed

    override func initializeViews() {

        self.addChild(viewController: self.feedVC, toView: self.contentContainer)
        self.addChild(self.channelsVC)

        self.contentContainer.addSubview(self.headerContainer)

        self.headerContainer.addSubview(self.avatarView)
        self.avatarView.onTap { [unowned self] (tap) in
            let vc = ProfileViewController()
            self.present(vc, animated: true, completion: {
                vc.set(avatar: Lorem.avatar())
            })
        }
        self.headerContainer.addSubview(self.searchImageView)

        self.headerContainer.addSubview(self.segmentControl)
        self.segmentControl.addTarget(self, action: #selector(updateContent), for: .valueChanged)

        self.contentContainer.addSubview(self.addButton)

        self.addButton.onTap { [unowned self] (tap) in
            self.presentContactPicker()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.headerContainer.size = CGSize(width: self.contentContainer.width, height: 40)
        self.headerContainer.top = Theme.contentOffset
        self.headerContainer.centerOnX()

        self.segmentControl.size = CGSize(width: 120, height: 40)
        self.segmentControl.centerOnXAndY()

        self.avatarView.size = CGSize(width: 30, height: 30)
        self.avatarView.left = 20
        self.avatarView.centerY = self.segmentControl.centerY

        self.searchImageView.size = CGSize(width: 22, height: 22)
        self.searchImageView.centerY = self.segmentControl.centerY
        self.searchImageView.right = self.headerContainer.width - 20

        self.addButton.size = CGSize(width: 60, height: 60)
        self.addButton.centerOnX()
        self.addButton.bottom = self.contentContainer.height - 25 - self.view.safeAreaInsets.bottom

        let feedHeight = (self.contentContainer.height * 0.8) - self.segmentControl.height - 30
        self.feedVC.view.size = CGSize(width: self.contentContainer.width * 0.85, height: feedHeight)
        self.feedVC.view.top = self.segmentControl.bottom + 30
        self.feedVC.view.left = self.contentContainer.width * 0.075

        self.channelsVC.view.size = self.contentContainer.size
        self.channelsVC.view.top = 0
        self.channelsVC.view.centerOnX()
    }

    func presentContactPicker() {
        let contactController = ContactsScrolledModalController()
        contactController.contactsVC.delegate = self
        self.present(contactController, animated: true, completion: nil)
    }

    private func resetContent(currentView: UIView, newView: UIView) {
        currentView.removeFromSuperview()
        self.contentContainer.insertSubview(newView, belowSubview: self.headerContainer)
        self.contentContainer.layoutNow()
        newView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        newView.alpha = 0
    }

    @objc func updateContent() {
        guard let newType = HomeContentType(rawValue: self.segmentControl.selectedSegmentIndex),
            self.currentType != newType else { return }

        switch newType {
        case .feed:
            self.channelsVC.animateOut { (completed, error) in
                if completed {
                    self.resetContent(currentView: self.channelsVC.view, newView: self.feedVC.view)
                    self.feedVC.animateIn(completion: { (completed, error) in })
                }
            }
        case .list:
            self.feedVC.animateOut { (completed, error) in
                if completed {
                    self.resetContent(currentView: self.feedVC.view, newView: self.channelsVC.view)
                    self.channelsVC.animateIn(completion: { (completed, error) in

                    })
                }
            }
        }

        self.currentType = newType
    }
}

extension HomeViewController: ContactsViewControllerDelegate {

    func contactsViewController(_ controller: ContactsViewController, didSelect contact: CNContact) {
        self.dismiss(animated: true) {
            guard let firstNumber = contact.phoneNumbers.first else { return }
            let stringNumber = firstNumber.value.stringValue.filter("0123456789".contains)

            guard let query = PFUser.query() else { return }
            query.whereKey("phoneNumber", equalTo: stringNumber)

            query.findObjectsInBackground(block: { (objects, error) in
                if let error = error {
                    print(error)
                }

                guard let user = objects?.first, let identifier = user.objectId else { return }
                self.createChannel(with: identifier)
            })
        }
    }

    func createChannel(with inviteeIdentifier: String) {
        ChannelManager.createChannel(channelName: "TEST CHANNEL", type: .private)
            .joinIfNeeded()
            .invite(personUserID: inviteeIdentifier)
            .withProgressBanner("Creating channel with TEST CHANNEL")
            .withErrorBanner()
            .ignoreUserInteractionEventsUntilDone()
            .observe { (result) in
                switch result {
                case .success(let channel):
                    let channelVC = ChannelViewController(channelType: .channel(channel))
                    self.present(channelVC, animated: true)
                case .failure(let error):
                    if let tomorrowError = error as? ClientError {
                        print(tomorrowError.localizedDescription)
                    } else {
                        print(error.localizedDescription)
                    }
                }
        }
    }
}
