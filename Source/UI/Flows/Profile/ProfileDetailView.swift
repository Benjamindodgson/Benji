//
//  ProfileDetailCell.swift
//  Benji
//
//  Created by Benji Dodgson on 10/15/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ProfileDetailView: View {
    
    let titleLabel = SmallLabel()
    let label = SmallBoldLabel()
    let button = Button()

    override func initializeSubviews() {
        super.initializeSubviews()
        self.addSubview(self.titleLabel)
        self.addSubview(self.label)
        self.addSubview(self.button)
        self.button.isHidden = true
    }

    func configure(with item: ProfileItem, for user: User) {

        self.button.isHidden = true

        switch item {
        case .picture:
            break
        case .name:
            self.titleLabel.set(text: "Name")
            self.label.set(text: user.fullName)
        case .localTime:
            self.titleLabel.set(text: "Local Time")
            self.label.set(text: Date.nowInLocalFormat)
        case .routine:
            self.titleLabel.set(text: "Routine")
            self.getRoutine(for: user)
        }

        self.layoutNow()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.titleLabel.size = CGSize(width: self.width - Theme.contentOffset, height: 20)
        self.titleLabel.left = 0
        self.titleLabel.top = 0

        self.label.size = self.titleLabel.size
        self.label.left = self.titleLabel.left
        self.label.top = self.titleLabel.bottom + 5

        self.button.size = CGSize(width: 100, height: 40)
        self.button.bottom = self.label.bottom
        self.button.pin(.right)
    }

    private func getRoutine(for user: User) {

        self.label.set(text: "NO ROUTINE SET")
        self.button.set(style: .normal(color: .lightPurple, text: "Set"))
        self.button.isHidden = false

        user.routine?.fetchIfNeededInBackground(block: { (object, error) in
            if let routine = object as? Routine, let date = routine.date {
                let formatter = DateFormatter()
                formatter.dateFormat = "h:mm a"
                let string = formatter.string(from: date)
                self.label.set(text: string)
                self.button.set(style: .normal(color: .lightPurple, text: "Update"))
            }

            self.layoutNow()
        })
    }
}
