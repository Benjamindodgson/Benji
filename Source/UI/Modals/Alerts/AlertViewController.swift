//
//  AlertViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 6/30/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROLocalization

class AlertViewController: ModalViewController {

    private(set) var alertView = AlertView()
    private let label = MediumLabel()
    private let text: Localized
    private(set) var buttonsContainer = UIView()
    private(set) var buttons: [Button] = []
    private lazy var alertTransitionDelegate = AlertControllerTransitioningDelegate()

    init(text: Localized, buttons: [LoadingButton]) {
        self.text = text
        self.buttons = buttons
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func initializeViews() {
        super.initializeViews()

        self.transitioningDelegate = self.alertTransitionDelegate

        self.label.set(text: self.text,
                       color: .white,
                       alignment: .center)

        self.view.addSubview(self.alertView)
        self.view.addSubview(self.buttonsContainer)
        self.buttonsContainer.set(backgroundColor: .clear)
        self.alertView.containerView.addSubview(self.getAlertContainerContentView())
    }

    func configure(text: Localized, buttons: [LoadingButton]) {

        self.label.set(text: text,
                       color: .white,
                       alignment: .center)

        self.buttons.removeAllFromSuperview(andRemoveAll: true)
        self.buttons = buttons
        self.buttons.forEach { button in
            self.buttonsContainer.addSubview(button)
        }
        
        self.view.layoutNow()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.alertView.width = self.view.width * 0.9
        self.alertView.containerView.width = self.alertView.width - 30
        self.buttonsContainer.width = self.alertView.width

        var yOffset: CGFloat = 0
        for (index, subview) in self.buttonsContainer.subviews.enumerated() {
            guard let button = subview as? UIButton else { return }
            button.frame = CGRect(x: 0,
                                  y: yOffset,
                                  width: self.alertView.width,
                                  height: Theme.buttonHeight)
            button.layer.cornerRadius = Theme.cornerRadius
            yOffset += button.height
            if index + 1 < self.buttons.count {
                yOffset += 10
            }
        }

        self.buttonsContainer.height = yOffset
        let containerHeight = self.getAlertContainerHeight(with: self.alertView.containerView.width)
        let height = 20 + containerHeight + yOffset + 25
        self.alertView.height = height

        self.alertView.containerView.height = containerHeight
        self.alertView.containerView.width = self.alertView.width - 20
        self.alertView.containerView.centerOnXAndY()

        let content = self.getAlertContainerContentView()
        content.size = self.alertView.containerView.size
        content.centerOnXAndY()

        self.buttonsContainer.top = self.alertView.bottom + self.getButtonsOffset()
        self.buttonsContainer.centerOnX()

        self.alertView.layer.cornerRadius = Theme.cornerRadius
        self.alertView.centerOnX()

        let bottomSpace = self.view.safeAreaInsets.bottom + self.view.width * 0.05
        self.alertView.bottom = self.view.height - bottomSpace - self.buttonsContainer.height
    }

    /// How far down the buttons are offset from the main content.
    private func getButtonsOffset() -> CGFloat {
        return 10
    }

    // MARK: Functions to Override

    /// Returns the view that should be put inside the container view: the main content of the alert. By default this is the basic text view,
    /// but subclasses can override this to provide their own custom content.
    func getAlertContainerContentView() -> UIView {
        return self.label
    }

    /// The height of the alert's main content. Sublcasses should override this if they provide their own custom content.
    func getAlertContainerHeight(with width: CGFloat) -> CGFloat {
        return self.label.getSize(withWidth: width).height
    }
}

private class AlertControllerTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    let transitionController = AlertControllerAnimatedTransitioning()

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        self.transitionController.isPresenting = true
        return self.transitionController
    }

    func animationController(forDismissed dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {

            self.transitionController.isPresenting = false
            return self.transitionController
    }
}
