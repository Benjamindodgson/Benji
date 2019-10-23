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

struct ProfileItem: ProfileDisplayable {
    var avatar: Avatar? = nil
    var title: String
    var text: String
    var hasDetail: Bool = false
}

protocol ProfileViewControllerDelegate: class {
    func profileView(_ controller: ProfileViewController, didSelectRoutineFor user: PFUser)
}

class ProfileViewController: ViewController {

    private let user: PFUser
    let topBar = View()
    lazy var collectionView = ProfileCollectionView()
    lazy var manager = ProfileCollectionViewManager(with: self.collectionView)
    unowned let delegate: ProfileViewControllerDelegate

    init(with user: PFUser, delegate: ProfileViewControllerDelegate) {
        self.user = user
        self.delegate = delegate
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = self.collectionView
    }

    override func initializeViews() {
        super.initializeViews()

        self.view.set(backgroundColor: .background1)

        self.collectionView.delegate = self.manager
        self.collectionView.dataSource = self.manager

        self.manager.didSelectItemAt = { [unowned self] indexPath in
            self.delegate.profileView(self, didSelectRoutineFor: self.user)
        }

        self.view.addSubview(self.topBar)
        self.topBar.set(backgroundColor: .background3)

        self.createItems()
    }

    private func createItems() {
        var items: [ProfileDisplayable] = []

        let avatarItem = ProfileItem(avatar: self.user,
                                     title: String(),
                                     text: String(),
                                     hasDetail: false)
        items.append(avatarItem)

        let handleItem = ProfileItem(avatar: nil,
                                     title: "Handle",
                                     text: self.user.handle,
                                     hasDetail: false)
        items.append(handleItem)

        let routineItem = ProfileItem(avatar: nil,
                                      title: "Routine",
                                      text: "7:00 PM",
                                      hasDetail: true)
        items.append(routineItem)

        self.manager.items = items
        self.collectionView.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.topBar.size = CGSize(width: 30, height: 4)
        self.topBar.top = 8
        self.topBar.centerOnX()
        self.topBar.layer.cornerRadius = 2
    }
}
