//
//  ScrolledModalViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 6/30/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ScrolledModalViewController<Presentable: ScrolledModalControllerPresentable>: ViewController, ScrolledModalContainerViewDelegate {

    var contentExpandedHeight: CGFloat {
        return self.view.height - self.presentable.topMargin
    }

    private(set) var tapDismissView = UIView()
    private(set) var modalContainerView: ScrolledModalContainerView
    private(set) var presentable: Presentable

    init(presentable: Presentable) {
        self.presentable = presentable
        self.modalContainerView = ScrolledModalContainerView(presentable: presentable)

        super.init()

        // You should be able to see the rest of the view hierarchy underneath this controller
        self.modalPresentationStyle = .overFullScreen

        self.modalContainerView.initialize(scrollingEnabled: self.presentable.scrollingEnabled)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func initializeViews() {
        super.initializeViews()

        self.view.set(backgroundColor: .clear)
        self.modalContainerView.delegate = self

        // The tap dismiss view should be added as the bottom most view so it doesn't prevent interactions
        // with the content.
        self.tapDismissView.set(backgroundColor: .backgroundWithAlpha)
        self.tapDismissView.alpha = 0

        self.view.addSubview(self.tapDismissView)
        self.tapDismissView.onTap { [unowned self] (tap) in
            self.modalContainerView.animateToHeight(height: 0)
        }

        self.view.addSubview(self.modalContainerView)

        self.addChild(viewController: self.presentable, toView: self.modalContainerView)
        self.presentable.didDismiss = { [unowned self] in
            self.dismiss(animated: true)
        }

        self.presentable.didUpdateHeight = { [unowned self] (height, duration) in
            let expandedHeight = self.getExpandedHeight() + height
            self.animate(height: expandedHeight, with: duration)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        once(caller: self, token: "setScrolledModalExpanded") {
            self.animate(height: self.getExpandedHeight(), with: Theme.animationDuration)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.tapDismissView.frame = self.view.bounds

        self.modalContainerView.size = CGSize(width: self.view.width,
                                              height: self.modalContainerView.currentHeight)
        self.modalContainerView.round(corners: [.topLeft, .topRight], size: CGSize(width: 10, height: 10))
        self.modalContainerView.centerOnX()
        self.modalContainerView.bottom = self.view.height

        self.presentable.view.frame = self.modalContainerView.bounds
    }

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        let expandedHeight = size.height - self.presentable.topMargin
        self.modalContainerView.setExpandedHeight(expandedHeight: expandedHeight)
    }

    func scrolledmodalContainerViewIsPanning(_ container: ScrolledModalContainerView,
                                             withProgress progress: Float) {
        self.updateAlpha(with: progress)
    }

    func scrolledModalContainerView(_ container: ScrolledModalContainerView,
                                    updated currentHeight: CGFloat) {
        self.view.layoutNow()
        self.updateAlpha(with: self.modalContainerView.progress)
    }

    func scrolledModalContainerViewFinishedAnimating(_ container: ScrolledModalContainerView,
                                                     withProgress progress: Float) {
        self.updateAlpha(with: progress)
        guard progress == 0 else { return }
        self.dismiss(animated: true, completion: nil)
    }

    private func animate(height: CGFloat, with duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.modalContainerView.setExpandedHeight(expandedHeight: height)
        }
    }

    private func updateAlpha(with progress: Float) {
        self.tapDismissView.alpha = CGFloat(progress)
    }

    private func getExpandedHeight() -> CGFloat {
        return self.view.height - self.presentable.topMargin
    }
}
