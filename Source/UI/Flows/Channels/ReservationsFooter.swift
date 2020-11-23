//
//  ReservationsFooter.swift
//  Benji
//
//  Created by Benji Dodgson on 5/26/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ReservationsFooter: UICollectionReusableView {

    var didSelectReservation: ((Reservation) -> Void)? = nil
    private var buttons: [ReservationButton] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeViews()
    }

    private func initializeViews() {

    }

    func configure() {
        self.getReservations()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        var xOffset: CGFloat = Theme.contentOffset
        self.buttons.forEach { (button) in
            button.setSize(with: self.width - 16)
            button.centerOnX()
            button.top = xOffset

            xOffset += button.height + Theme.contentOffset
        }
    }

    private func getReservations() {
        guard let user = User.current() else { return }

        Reservation.getReservations(for: user)
            .observeValue { [weak self] (reservations) in
                guard let `self` = self else { return }
                self.layout(reservations: Array.init(reservations.prefix(3)))
        }
    }

    func layout(reservations: [Reservation]) {
        self.buttons = []
        self.removeAllSubviews()

        var index = 1
        reservations.forEach { (reservation) in
            if !reservation.isClaimed {
                let button = ReservationButton(with: reservation)
                button.set(style: .normal(color: .purple, text: "Invite \(index)"))
                button.didSelect = { [weak self] in
                    guard let `self` = self else { return }
                    self.didSelect(button: button)
                }
                self.buttons.append(button)
                self.addSubview(button)
                index += 1
            }
        }

        self.layoutNow()
    }

    private func didSelect(button: ReservationButton) {
        button.isLoading = true
        button.reservation.prepareMetaData()
            .observeValue { (_) in
                self.didSelectReservation?(button.reservation)
                runMain {
                    button.isLoading = false
                }
        }
    }
}

private class ReservationButton: LoadingButton {
    let reservation: Reservation

    init(with reservation: Reservation) {
        self.reservation = reservation
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
