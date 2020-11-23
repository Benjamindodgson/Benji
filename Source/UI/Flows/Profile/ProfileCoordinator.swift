//
//  ProfileCoordinator.swift
//  Benji
//
//  Created by Benji Dodgson on 10/5/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse
import Branch

class ProfileCoordinator: Coordinator<Void> {

    let profileVC: ProfileViewController

    init(router: Router,
         deepLink: DeepLinkable?,
         profileVC: ProfileViewController) {

        self.profileVC = profileVC

        super.init(router: router, deepLink: deepLink)
    }

    override func start() {

        self.profileVC.delegate = self

        if let link = self.deepLink, let target = link.deepLinkTarget, target == .routine {
            self.presentRoutine()
        }
    }

    private func presentRoutine() {
        let coordinator = RoutineCoordinator(router: self.router, deepLink: self.deepLink)
        self.addChildAndStart(coordinator) { (resutl) in }
        self.router.present(coordinator, source: self.profileVC)
    }

    private func presentPhoto() {
        let vc = ProfilePhotoViewController(with: self)
        self.router.present(vc, source: self.profileVC)
    }
}

extension ProfileCoordinator: ProfileViewControllerDelegate {

    func profileView(_ controller: ProfileViewController, didSelect item: ProfileItem, for user: User) {
        guard user.isCurrentUser else { return }

        switch item {
        case .routine:
            self.presentRoutine()
        case .picture:
            self.presentPhoto()
        default:
            break 
        }
    }
}

extension ProfileCoordinator: ProfilePhotoViewControllerDelegate {
    func profilePhotoViewControllerDidFinish(_ controller: ProfilePhotoViewController) {
        controller.dismiss(animated: true) {
            guard let user = User.current() else { return }
            self.profileVC.updateItems(with: user)
        }
    }
}
