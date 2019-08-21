//
//  ScrolledModalFlowViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 8/10/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ScrolledModalFlowViewController: ViewController, ScrolledModalControllerPresentable, KeyboardObservable {

    var didUpdateHeight: ((CGFloat, TimeInterval) -> ())?

    var maxHeight: CGFloat = 100
    var topMargin: CGFloat = 54
    var scrollView: UIScrollView? = UIScrollView()
    let scrollingEnabled: Bool = true
    var didExit: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.registerKeyboardEvents()

        if let sv = self.scrollView {
            self.view.addSubview(sv)
            sv.isScrollEnabled = false
            sv.isPagingEnabled = true
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let sv = self.scrollView {
            sv.frame = self.view.bounds
            var xOffset: CGFloat = 0
            for (index, child) in self.children.enumerated() {
                xOffset = CGFloat(index) * sv.width
                child.view.frame = CGRect(x: xOffset, y: 0, width: sv.width, height: sv.height)
            }
            sv.contentSize = CGSize(width: xOffset + sv.width, height: sv.height)
        }
    }

    func add(controller: UIViewController) {
        self.addChild(viewController: controller, toView: self.scrollView)
        self.view.layoutNow()
    }

    @discardableResult
    func moveForward(incrementalAmount: Int = 1) -> Bool {
        guard let sv = self.scrollView else { return false }

        if sv.currentXIndex < self.children.count - incrementalAmount {
            let nextPage = self.children[sv.currentXIndex + incrementalAmount]
            sv.scrollHorizontallyTo(view: nextPage.view, animated: true)
            return true
        }

        return false
    }

    @discardableResult
    func moveBackward(decrementalAmount: Int = 1) -> Bool {
        guard let sv = self.scrollView else { return false }

        if sv.currentXIndex - decrementalAmount >= 0 {
            let previousPage = self.children[sv.currentXIndex - decrementalAmount]
            sv.scrollHorizontallyTo(view: previousPage.view, animated: true)
            return true
        }

        return false
    }

    func handleKeyboard(height: CGFloat, with animationDuration: TimeInterval) {
        self.didUpdateHeight?(height, animationDuration)
    }
}
