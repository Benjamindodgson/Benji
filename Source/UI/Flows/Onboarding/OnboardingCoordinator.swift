//
//  LoginCoordinator.swift
//  Benji
//
//  Created by Benji Dodgson on 8/10/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import PhoneNumberKit
import Parse

class OnboardingCoordinator: PresentableCoordinator<Void> {

    lazy var onboardingVC = OnboardingViewController(with: self.reservationId,
                                                     reservationCreatorId: self.reservationCreatorId,
                                                     deeplink: self.deepLink,
                                                     delegate: self)
    let reservationId: String?
    let reservationCreatorId: String?

    init(reservationId: String?,
         reservationCreatorId: String?,
         router: Router,
         deepLink: DeepLinkable?) {

        self.reservationId = reservationId
        self.reservationCreatorId = reservationCreatorId

        super.init(router: router, deepLink: deepLink)
    }

    override func toPresentable() -> DismissableVC {
        return self.onboardingVC
    }

    func handle(deeplink: DeepLinkable?) {
        guard let link = deeplink else { return }
        self.onboardingVC.deeplink = link
        self.onboardingVC.reservationId = link.reservationId
        self.onboardingVC.reservationCreatorId = link.reservationCreatorId
        self.onboardingVC.updateNavigationBar()
    }
}

extension OnboardingCoordinator: OnboardingViewControllerDelegate {
    func onboardingView(_ controller: OnboardingViewController, didVerify user: PFUser) {
        self.finishFlow(with: ())
    }
}
