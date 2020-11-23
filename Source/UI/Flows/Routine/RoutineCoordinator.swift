//
//  RoutineCoordinator.swift
//  Benji
//
//  Created by Benji Dodgson on 2/23/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

class RoutineCoordinator: PresentableCoordinator<Void> {

    lazy var routineVC = RoutineViewController(with: self)

    override func toPresentable() -> DismissableVC {
        return self.routineVC
    }
}

extension RoutineCoordinator: RoutineViewControllerDelegate {

    func routineInputViewControllerNeedsAuthorization(_ controller: RoutineViewController) {
        UserNotificationManager.shared.register(application: UIApplication.shared) { (success, error) in
            runMain {
                if success {
                    controller.routineInputVC.currentState.value = .update
                } else if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
                }
            }
        }
    }
}
