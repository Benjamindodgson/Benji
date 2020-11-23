//
//  MeditationCoordinator.swift
//  Benji
//
//  Created by Benji Dodgson on 4/11/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

class MeditationCoordinator: PresentableCoordinator<Void> {

    lazy var meditationVC = MeditationViewController(with: self)

    override func toPresentable() -> PresentableCoordinator<Void>.DismissableVC {
        return self.meditationVC
    }
}

extension MeditationCoordinator: MeditationViewControllerDelegate {

    func meditationViewControllerDidFinish(_ controller: MeditationViewController) {
        runMain {
            self.finishFlow(with: ())
        }
    }
}
