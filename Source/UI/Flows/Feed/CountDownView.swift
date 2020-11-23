//
//  CountDownView.swift
//  Benji
//
//  Created by Benji Dodgson on 12/5/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class CountDownView: View {

    private let timeLabel = ComponentLabel()
    private(set) var timer: Timer?
    private var referenceDate: Date?

    var didExpire: () -> Void = {}

    override func initializeSubviews() {
        super.initializeSubviews()

        self.addSubview(self.timeLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.timeLabel.expandToSuperviewSize()
    }

    func startTimer(with date: Date) {
        self.referenceDate = date
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 1.0,
                                          target: self,
                                          selector: #selector(fireTimer),
                                          userInfo: nil,
                                          repeats: true)
        self.timer?.fire()
    }

    @objc private func fireTimer() {
        self.updateLabels()
    }

    private func updateLabels() {
        guard let refDate = self.referenceDate else { return }
        let now = Date()

        // If the present time is greater than the referenceDate than the countdown is expired.
        if now > refDate {
            self.timer?.invalidate()
            self.timeLabel.set(value: "00 : 00")
            self.didExpire()
        } else {
            // Otherwise get the differnce in DateComponents
            let components = self.getTime(from: now, to: refDate)
            let time = String(format: "%.2d : %.2d",
                              components.minute ?? 00,
                              components.second ?? 00)

            self.timeLabel.set(value: time)
        }
    }

    private func getTime(from now: Date, to reference: Date) -> DateComponents {
        return Calendar.current.dateComponents([.minute, .second],
                                               from: now,
                                               to: reference)
    }
}

private class ComponentLabel: DisplayThinLabel {

    func set(value: String) {
        self.set(text: value, color: .white, alignment: .center)
    }
}
