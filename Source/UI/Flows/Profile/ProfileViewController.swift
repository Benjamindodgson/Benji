//
//  ProfileViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 7/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse
import TwilioChatClient
import TMROLocalization

protocol ProfileViewControllerDelegate: class {
    func profileView(_ controller: ProfileViewController, didSelect item: ProfileItem, for user: User)
}

class ProfileViewController: ViewController {

    private let user: User
    weak var delegate: ProfileViewControllerDelegate?

    private let scrollView = UIScrollView()
    private(set) var avatarView = AvatarView()
    private let nameView = ProfileDetailView()
    private let localTimeView = ProfileDetailView()
    private let routineView = ProfileDetailView()

    init(with user: User) {
        self.user = user
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = self.scrollView
    }

    override func initializeViews() {
        super.initializeViews()

        self.view.addSubview(self.avatarView)
        self.avatarView.set(avatar: self.user)
        self.avatarView.didSelect = { [unowned self] in
            self.delegate?.profileView(self, didSelect: .picture, for: self.user)
        }

        self.view.addSubview(self.nameView)
        self.view.addSubview(self.localTimeView)
        self.view.addSubview(self.routineView)
        self.routineView.button.isVisible = true 
        self.routineView.button.didSelect = { [unowned self] in
            self.delegate?.profileView(self, didSelect: .routine, for: self.user)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.updateItems(with: self.user)
    }

    func updateItems(with user: User) {
        self.nameView.configure(with: .name, for: user)
        self.localTimeView.configure(with: .localTime, for: user)
        self.routineView.configure(with: .routine, for: user)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.avatarView.setSize(for: self.view.width * 0.4)
        self.avatarView.pin(.top)
        self.avatarView.pin(.left, padding: Theme.contentOffset)

        let itemSize = CGSize(width: self.view.width - (Theme.contentOffset * 2), height: 60)

        self.nameView.size = itemSize
        self.nameView.match(.top, to: .bottom, of: self.avatarView, offset: Theme.contentOffset)
        self.nameView.pin(.left, padding: Theme.contentOffset)

        self.localTimeView.size = itemSize
        self.localTimeView.match(.top, to: .bottom, of: self.nameView, offset: Theme.contentOffset)
        self.localTimeView.pin(.left, padding: Theme.contentOffset)

        self.routineView.size = itemSize
        self.routineView.match(.top, to: .bottom, of: self.localTimeView, offset: Theme.contentOffset)
        self.routineView.pin(.left, padding: Theme.contentOffset)

        self.scrollView.contentSize = CGSize(width: self.view.width, height: self.routineView.bottom)
    }
}
