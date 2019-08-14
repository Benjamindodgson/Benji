//
//  ProfileViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 7/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ProfileViewController: FullScreenViewController {

    let avatarView = AvatarView()
    let closeButton = CloseButton()
    let displayLabel = Display2Label()
    let handleLabel = RegularSemiBoldLabel()

    let routineInputVC = RoutineInputViewController()

    override func initializeViews() {
        super.initializeViews()

        self.contentContainer.addSubview(self.avatarView)
        self.contentContainer.addSubview(self.closeButton)
        self.closeButton.onTap { [unowned self] (tap) in
            self.dismiss(animated: true, completion: nil)
        }
        self.contentContainer.addSubview(self.displayLabel)
        self.contentContainer.addSubview(self.handleLabel)

        self.addChild(viewController: self.routineInputVC, toView: self.contentContainer)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.closeButton.left = 18
        self.closeButton.top = 10

        self.avatarView.size = CGSize(width: 54, height: 54)
        self.avatarView.top = self.closeButton.bottom + 15
        self.avatarView.left = self.closeButton.left

        self.displayLabel.setSize(withWidth: self.contentContainer.width * 0.7)
        self.displayLabel.top = self.avatarView.top
        self.displayLabel.left = self.avatarView.right + 15

        self.handleLabel.setSize(withWidth: self.contentContainer.width * 0.7)
        self.handleLabel.bottom = self.avatarView.bottom
        self.handleLabel.left = self.displayLabel.left

        self.routineInputVC.view.frame = CGRect(x: 0,
                                                y: self.avatarView.bottom + 20,
                                                width: self.view.width,
                                                height: 250)
    }

    func set(avatar: Avatar) {
        self.avatarView.set(avatar: avatar)
        self.displayLabel.set(text: avatar.firstName)
        self.handleLabel.set(text: avatar.handle, color: .lightPurple)

        self.view.setNeedsLayout()
    }
}
