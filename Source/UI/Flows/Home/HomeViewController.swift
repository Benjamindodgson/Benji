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
import ReactiveSwift

enum HomeContent: Equatable {
    case feed(FeedViewController)
    case channels(ChannelsViewController)
    case profile(ProfileViewController)
}

protocol HomeViewControllerDelegate: class {
    func homeViewDidTapAdd(_ controller: HomeViewController)
}

typealias HomeDelegate = HomeViewControllerDelegate

class HomeViewController: FullScreenViewController {

    unowned let delegate: HomeDelegate

    lazy var feedVC = FeedViewController()
    lazy var channelsVC = ChannelsViewController()
    lazy var profileVC = ProfileViewController(with: User.current()!)
    lazy var searchBar = SearchBar()

    let centerContainer = View()
    let tabView = HomeTabView()

    lazy var currentContent = MutableProperty<HomeContent>(.feed(self.feedVC))
    private(set) var currentCenterVC: UIViewController?

    init(with delegate: HomeDelegate) {
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

        self.searchBar.isHidden = true
        self.searchBar.delegate = self.channelsVC
        self.contentContainer.addSubview(self.searchBar)

        self.view.set(backgroundColor: .background1)

        self.contentContainer.addSubview(self.centerContainer)

        self.contentContainer.addSubview(self.tabView)

        self.currentContent.producer
            .skipRepeats()
            .on(value:  { [unowned self] (contentType) in
                self.switchContent()
                self.tabView.updateTabItems(for: contentType)
            }).start()

        self.tabView.profileItem.didSelect = { [unowned self] in
            self.currentContent.value = .profile(self.profileVC)
        }

        self.tabView.feedItem.didSelect = { [unowned self] in
            self.currentContent.value = .feed(self.feedVC)
        }

        self.tabView.channelsItem.didSelect = { [unowned self] in
            self.currentContent.value = .channels(self.channelsVC)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.searchBar.size = CGSize(width: self.contentContainer.width - (16 * 2), height: 44)
        self.searchBar.centerOnX()

        let height = 70 + self.view.safeAreaInsets.bottom
        self.tabView.size = CGSize(width: self.contentContainer.width, height: height)
        self.tabView.centerOnX()
        self.tabView.bottom = self.contentContainer.height + self.view.safeAreaInsets.bottom

        self.centerContainer.size = CGSize(width: self.contentContainer.width,
                                           height: self.contentContainer.height - 156)
        self.centerContainer.bottom = self.tabView.top
        self.centerContainer.centerOnX()

        self.searchBar.bottom = self.centerContainer.top

        self.currentCenterVC?.view.frame = self.centerContainer.bounds
    }

    private func switchContent() {

        UIView.animate(withDuration: Theme.animationDuration, animations: {
            self.centerContainer.alpha = 0
            self.centerContainer.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { (completed) in

            self.currentCenterVC?.removeFromParentSuperview()
            var newContentVC: UIViewController?

            switch self.currentContent.value {
            case .feed(let vc):
                newContentVC = vc
                self.searchBar.isHidden = true
            case .channels(let vc):
                newContentVC = vc
                self.searchBar.isHidden = false
            case .profile(let vc):
                newContentVC = vc
                self.searchBar.isHidden = true
            }

            self.currentCenterVC = newContentVC

            if let contentVC = self.currentCenterVC {
                self.addChild(viewController: contentVC, toView: self.centerContainer)
            }

            self.view.setNeedsLayout()

            UIView.animate(withDuration: Theme.animationDuration) {
                self.centerContainer.alpha = 1
                self.centerContainer.transform = .identity
            }
        }
    }
}
