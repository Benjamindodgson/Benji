//
//  ReservationsCoordinator.swift
//  Benji
//
//  Created by Benji Dodgson on 5/30/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ReservationsCoordinator: Coordinator<Void> {

    let reservation: Reservation

    init(reservation: Reservation,
         router: Router,
         deepLink: DeepLinkable?) {

        self.reservation = reservation
        super.init(router: router, deepLink: deepLink)
    }

    override func start() {
        super.start()

        if let _ = self.reservation.metadata {
            self.presentShare(for: reservation)
        } else {
            self.reservation.prepareMetaData()
                .observeValue { [unowned self] (_) in
                    self.presentShare(for: self.reservation)
            }
        }
    }

    private func presentShare(for reservation: Reservation) {
        runMain {
            let ac = UIActivityViewController(activityItems: [reservation], applicationActivities: nil)
            ac.completionWithItemsHandler = { activityType, completed, items, error in
                self.showAlert()
            }
            self.router.navController.present(ac, animated: true)
        }
    }

    private func showAlert() {
        let alert = UIAlertController(title: "Invitation Sent",
                                      message: "Your invation has been sent. As soon as someone accepts, using your link, a conversation will be created between the two of you.",
                                      preferredStyle: .alert)

        let ok = UIAlertAction(title: "Ok", style: .cancel) { (_) in
            self.finishFlow(with: ())
        }

        alert.addAction(ok)

        self.router.navController.present(alert, animated: true, completion: nil)
    }
}
