//
//  ConnectionContentView.swift
//  Benji
//
//  Created by Benji Dodgson on 4/5/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Lottie
import PhoneNumberKit
import TMROLocalization

class ConnectionContentView: View {

    private let avatarView = AvatarView()
    private let nameLabel = RegularBoldLabel()
    private let routineLabel = SmallLabel()
    private(set) var animationView = AnimationView(name: "checkbox")

    override func initializeSubviews() {
        super.initializeSubviews()

        self.addSubview(self.avatarView)
        self.addSubview(self.nameLabel)
        self.addSubview(self.routineLabel)
        self.addSubview(self.animationView)
    }

    func configure(with connection: Connection) {

        connection.nonMeUser?.fetchIfNeededInBackground { (object, error) in
            guard let nonMeUser = object as? User else { return }
            self.set(user: nonMeUser)
        }
    }

    private func set(user: User) {

        self.nameLabel.set(text: user.fullName, stringCasing: .capitalized)
        self.routineLabel.set(text: "No routine set yet.")
        user.routine?.fetchIfNeededInBackground(block: { (object, error) in
            if let routine = object as? Routine, let date = routine.date {
                let formatter = DateFormatter()
                formatter.dateFormat = "h:mm a"
                let string = formatter.string(from: date)
                let routineText = LocalizedString(id: "", arguments: [user.givenName, string], default: "@(name)'s routine is: @(routine)")
                self.routineLabel.set(text: routineText)
            }
        })

        self.avatarView.set(avatar: user)

        self.layoutNow()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.avatarView.setSize(for: 60)
        self.avatarView.left = Theme.contentOffset
        self.avatarView.centerOnY()

        let width = self.width - self.avatarView.right - (Theme.contentOffset * 2)
        self.nameLabel.size = CGSize(width: width, height: 30)
        self.nameLabel.bottom = self.avatarView.centerY
        self.nameLabel.left = self.avatarView.right + Theme.contentOffset

        self.routineLabel.size = CGSize(width: width, height: 30)
        self.routineLabel.top = self.avatarView.centerY
        self.routineLabel.left = self.avatarView.right + Theme.contentOffset

        self.animationView.size = CGSize(width: 20, height: 20)
        self.animationView.centerOnY()
        self.animationView.right = self.right - Theme.contentOffset
    }

    func animateToChecked() {
        self.animationView.play(toFrame: 30)
    }

    func animateToUnchecked() {
        self.animationView.play(fromFrame: 30, toFrame: 0, loopMode: nil, completion: nil)
    }
}
