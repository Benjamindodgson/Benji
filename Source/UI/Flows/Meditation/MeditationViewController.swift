//
//  MeditationViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 4/11/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROLocalization

protocol MeditationViewControllerDelegate: class {
    func meditationViewControllerDidFinish(_ controller: MeditationViewController)
}

class MeditationViewController: NavigationBarViewController {

    private let emojiLabel = DisplayThinLabel()
    private let circleView = View()
    private let label = SmallLabel()
    private let button = LoadingButton()

    private var startDate: Date?
    private var endDate: Date?

    private var animator: UIViewPropertyAnimator?
    var shouldFinish: Bool = false

    unowned let delegate: MeditationViewControllerDelegate

    init(with delegate: MeditationViewControllerDelegate) {
        self.delegate = delegate
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func initializeViews() {
        super.initializeViews()

        self.backButton.isHidden = true
        self.view.addSubview(self.circleView)
        self.circleView.set(backgroundColor: .lightPurple)
        self.circleView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        self.circleView.alpha = 0

        self.view.addSubview(self.emojiLabel)
        self.view.addSubview(self.label)
        self.label.set(text: "Well done.", color: .white, alignment: .center)
        self.label.alpha = 0

        self.view.addSubview(self.button)
        self.button.set(style: .normal(color: .purple, text: "Record"))
        self.button.didSelect = { [unowned self] in
            self.handleButtonTap()
        }
        self.button.alpha = 0
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.circleView.size = CGSize(width: self.view.width * 0.8, height: self.view.width * 0.8)
        self.circleView.centerOnXAndY()
        self.circleView.layer.cornerRadius = self.circleView.halfHeight

        self.emojiLabel.size = CGSize(width: 80, height: 80)
        self.emojiLabel.centerOnXAndY()

        self.label.setSize(withWidth: self.view.width)
        self.label.centerOnX()
        self.label.top = self.emojiLabel.bottom

        self.button.setSize(with: self.view.width)
        self.button.bottom = self.view.height - self.view.safeAreaInsets.bottom
        self.button.centerOnX()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.emojiLabel.set(text: "🧘‍♀️", color: .clear, alignment: .center)

        self.runAnimation()

        self.startDate = Date()
        delay(60) {
            self.endDate = Date()
            self.shouldFinish = true
        }
    }

    override func getTitle() -> Localized {
        return "Mindful Minute"
    }

    override func getDescription() -> Localized {
        return "Take a minute to focus on your breathing, and think about others you care about."
    }

    private func runAnimation() {
        self.circleView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)

        UIView.animate(withDuration: 1.5, delay: 1.0, options: .curveEaseInOut, animations: {
            self.circleView.transform = .identity
            self.circleView.alpha = 1
        }) { (completed) in
            UIView.animate(withDuration: 1.5, delay: 0.0, options: .curveEaseInOut, animations: {
                self.circleView.alpha = 0
            }) { (_) in
                if !self.shouldFinish {
                    self.runAnimation()
                } else {
                    self.animateFinal()
                }
            }
        }
    }

    private func animateFinal() {
        self.button.transform = CGAffineTransform(translationX: 1.0, y: 100)
        self.button.alpha = 1

        UIView.animate(withDuration: Theme.animationDuration) {
            self.button.transform = .identity
        }

        UIView.animate(withDuration: Theme.animationDuration, delay: 0, options: .curveEaseInOut, animations: {
            self.emojiLabel.alpha = 0
        }) { (_) in
            self.emojiLabel.set(text: "😌", color: .clear, alignment: .center)
            UIView.animate(withDuration: Theme.animationDuration) {
                self.emojiLabel.alpha = 1
                self.label.alpha = 1 
            }
        }
    }

    private func handleButtonTap() {
        self.button.isLoading = true
        HealthKitManager.shared.requestAuthorization { [unowned self] (success, error) in
            self.button.isLoading = false

            if success {
                self.updateMindfulMintutes()
            } else {
                self.delegate.meditationViewControllerDidFinish(self)
            }
        }
    }

    private func updateMindfulMintutes() {
        guard let start = self.startDate, let end = self.endDate else {
            self.delegate.meditationViewControllerDidFinish(self)
            return
        }

        HealthKitManager.shared.saveMindfullAnalysis(startTime: start, endTime: end) { [unowned self] (success, error) in
            self.delegate.meditationViewControllerDidFinish(self)
        }
    }
}
