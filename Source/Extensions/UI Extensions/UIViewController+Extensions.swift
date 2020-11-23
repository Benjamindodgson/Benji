//
//  UIViewController+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 12/29/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension UIViewController {
    
    func addChild(viewController: UIViewController, toView: UIView? = nil) {
        let view: UIView = toView ?? self.view

        self.addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }

    func removeFromParentSuperview() {
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }

    func topmostViewController() -> UIViewController {
        if let presentedViewController = self.presentedViewController {
            return presentedViewController.topmostViewController()
        }

        if let navController = self as? UINavigationController,
            let topVC = navController.topViewController {
            return topVC
        } else if let tabBarController = self as? UITabBarController {
            if let currentVC = tabBarController.selectedViewController {
                return currentVC
            }
        }

        return self
    }
}
