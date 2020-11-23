//
//  HomeStackViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 6/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Koloda
import TMROLocalization

protocol FeedViewControllerDelegate: class {
    func feedView(_ controller: FeedViewController, didSelect item: FeedType)
}

class FeedViewController: ViewController {

    private let collectionView = FeedCollectionView()

    lazy var manager: FeedCollectionViewManager = {
        let manager = FeedCollectionViewManager(with: self.collectionView)
        manager.didComplete = { [unowned self] feedType in
            self.delegate?.feedView(self, didSelect: feedType)
        }
        manager.didFinish = { [unowned self] in
            self.showReload()
        }
        manager.didShowCardAtIndex = { [unowned self] index in
            self.indicatorView.update(to: index)
        }
        return manager
    }()

    weak var delegate: FeedViewControllerDelegate?
    var items: [FeedType] = [] {
        didSet {
            self.indicatorView.configure(with: self.items.count)
        }
    }
    private let countDownView = CountDownView()
    private let messageLabel = MediumLabel()
    private let reloadButton = Button()
    private let indicatorView = FeedIndicatorView()

    var message: Localized? {
        didSet {
            guard let text = self.message else { return }
            self.messageLabel.set(text: text, alignment: .center)
        }
    }
    private var currentTriggerDate: Date? {
        return UserDefaults.standard.value(forKey: Routine.currentRoutineKey) as? Date
    }

    private let shouldShowFeed: Bool = false

    override func initializeViews() {
        super.initializeViews()

        self.view.addSubview(self.messageLabel)
        self.view.addSubview(self.reloadButton)
        self.messageLabel.alpha = 0
        self.reloadButton.alpha = 0
        self.view.addSubview(self.countDownView)
        self.view.addSubview(self.indicatorView)
        self.view.addSubview(self.collectionView)
        self.indicatorView.alpha = 0

        self.countDownView.didExpire = { [unowned self] in
            self.subscribeToUpdates()
        }

        self.reloadButton.set(style: .normal(color: .purple, text: "Reload"))
        self.reloadButton.didSelect = { [unowned self] in
            self.reloadFeed()
        }

        self.collectionView.dataSource = self.manager
        self.collectionView.delegate = self.manager
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        onceEver(token: "loadOrSubscribeToFeed") {
            if self.shouldShowFeed {
                self.subscribeToUpdates()
            } else {
                self.loadFeed()
            }
        }
    }

    private func loadFeed() {

        User.current()?.getRoutine()
            .observe(with: { (result) in
                switch result {
                case .success(let routine):
                    self.items = []
                    self.determineMessage(with: routine)
                case .failure(_):
                    self.addFirstItems()
                }
            })
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.messageLabel.setSize(withWidth: self.view.width * 0.8)
        self.messageLabel.centerY = self.view.halfHeight * 0.8
        self.messageLabel.centerOnX()

        self.reloadButton.size = CGSize(width: 140, height: 40)
        self.reloadButton.top = self.messageLabel.bottom + 40
        self.reloadButton.centerOnX()

        self.countDownView.size = CGSize(width: 200, height: 60)
        self.countDownView.centerY = self.view.halfHeight * 0.8
        self.countDownView.centerOnX()

        self.collectionView.expandToSuperviewSize()

        self.indicatorView.size = CGSize(width: self.view.width - 40, height: 2)
        self.indicatorView.top = 5
        self.indicatorView.centerOnX()
    }

    private func showReload() {
        runMain {
            self.messageLabel.set(text: "You are all caught up!\nSee you tomorrow 🤗", alignment: .center)
            self.view.bringSubviewToFront(self.reloadButton)
            self.view.layoutNow()
            UIView.animate(withDuration: Theme.animationDuration, delay: Theme.animationDuration, options: .curveEaseInOut, animations: {
                self.reloadButton.alpha = 1
                self.messageLabel.alpha = 1
                self.indicatorView.alpha = 0
            }, completion: { _ in })
        }
    }

    private func reloadFeed() {
        self.view.sendSubviewToBack(self.reloadButton)
        UIView.animate(withDuration: Theme.animationDuration, delay: 0, options: .curveEaseInOut, animations: {
            self.reloadButton.alpha = 0
            self.messageLabel.alpha = 0
            self.indicatorView.alpha = 1 
        }, completion: { completed in
            self.manager.reload()
            self.indicatorView.update(to: 0)
        })
    }

    private func determineMessage(with routine: Routine) {
        guard let triggerDate = routine.date,
            self.currentTriggerDate != triggerDate,
            let anHourAfter = triggerDate.add(component: .hour, amount: 1),
            let anHourUntil = triggerDate.subtract(component: .hour, amount: 1) else { return }

        self.items = []

        //Set the current trigger date so we dont reload for duplicates
        UserDefaults.standard.set(triggerDate, forKey: Routine.currentRoutineKey)

        let now = Date()
        
        //If date is 1 hour or less away, show countDown
        if now.isBetween(anHourUntil, and: triggerDate) {
            self.countDownView.startTimer(with: triggerDate)
            self.showCountDown()

            //If date is less than an hour ahead of current date, show feed
        } else if now.isBetween(triggerDate, and: anHourAfter) {
            self.subscribeToUpdates()

        //If date is 1 hour or more away, show "see you at (date)"
        } else if now.isBetween(Date().beginningOfDay, and: anHourUntil) {
            let dateString = Date.hourMinuteTimeOfDay.string(from: triggerDate)
            self.message = "Take a break! ☕️\nSee you at \(dateString)"
            self.showMessage()
        } else {
            let dateString = Date.hourMinuteTimeOfDay.string(from: triggerDate)
            self.message = "See you tomorrow at \n\(dateString)"
            self.showMessage()
        }

        self.view.layoutNow()
    }

    private func showCountDown() {
        self.messageLabel.alpha = 0
        self.countDownView.alpha = 0
        self.countDownView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)

        UIView.animate(withDuration: Theme.animationDuration, animations: {
            self.countDownView.transform = .identity
            self.countDownView.alpha = 1
        }, completion: nil)
    }

    private func showMessage() {

        self.countDownView.alpha = 0
        self.messageLabel.alpha = 0
        self.view.layoutNow()
        self.messageLabel.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)

        UIView.animate(withDuration: Theme.animationDuration, animations: {
            self.messageLabel.transform = .identity
            self.messageLabel.alpha = 1
        }, completion: nil)
    }

    func showFeed() {
        runMain {
            UIView.animate(withDuration: Theme.animationDuration, delay: 0, options: [], animations: {
                self.countDownView.alpha = 0
                self.countDownView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                self.indicatorView.alpha = 1
            }, completion: nil)

            self.manager.set(items: self.items)
        }
    }
}
