//
//  CenterViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 12/27/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

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

            ChannelManager.createChannel(channelName: "TEST CHANNEL", uniqueName: "TESTCHANNEL", type: .public)
                .withProgressBanner("Creating channel with TEST CHANNEL")
                .withErrorBanner()
                .ignoreUserInteractionEventsUntilDone()
                .observe { (result) in
                    switch result {
                    case .success(let channel):
                        let channelVC = ChannelViewController()
                        self.present(channelVC, animated: true) {
                            channelVC.loadMessages(for: .channel(channel))
                        }
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

    private func resetContent(currentView: UIView, newView: UIView) {
        currentView.removeFromSuperview()
        self.contentContainer.insertSubview(newView, belowSubview: self.headerContainer)
        self.contentContainer.layoutNow()
        newView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        newView.alpha = 0
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


