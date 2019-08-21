//
//  LoginCoordinator.swift
//  Benji
//
//  Created by Benji Dodgson on 8/10/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class LoginCoordinator: PresentableCoordinator<Void> {

    var userExists: Bool

    lazy var loginFlowController: LoginFlowViewController = {
        let controller = LoginFlowViewController(introVC: nil,
                                                 endingVC: nil,
                                                 userExists: self.userExists)
        controller.delegate = self
        return controller
    }()

    lazy var scrolledModal = ScrolledModalViewController(presentable: self.loginFlowController)

    init(router: Router, userExists: Bool) {
        self.userExists = userExists

        super.init(router: router, deepLink: nil)
    }

    override func toPresentable() -> DismissableVC {
        return self.scrolledModal
    }

    override func start() {
        self.scrolledModal.didDismiss = { [unowned self] in
            self.finishFlow(with: ())
        }
    }
}

extension LoginCoordinator: LoginFlowViewControllerDelegate {
    func loginFlowViewController(_ controller: LoginFlowViewController, finishedWith result: LoginFlowResult) {
        switch result {
        case .loggedIn:
            self.scrolledModal.dismiss(animated: true, completion: nil)
        case .cancelled:
            break 
        }
    }
}
