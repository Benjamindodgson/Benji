//
//  UIWindow+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 7/1/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension UIWindow {

    static func topWindow() -> UIWindow? {
        for window in UIApplication.shared.windows.reversed() {
            if window.windowLevel == UIWindow.Level.normal && window.isKeyWindow && window.frame != CGRect.zero { return window }
        }
        return nil
    }

    static func topMostController() -> UIViewController? {
        guard let window = UIWindow.topWindow() else { return nil }
        return window.topMostViewController()
    }

    func topMostViewController() -> UIViewController? {
        guard let rootViewController = self.rootViewController else {
            return nil
        }
        return self.topViewController(for: rootViewController)
    }

    func topViewController(for rootViewController: UIViewController?) -> UIViewController? {
        guard let rootViewController = rootViewController else {
            return nil
        }
        guard let presentedViewController = rootViewController.presentedViewController else {
            return rootViewController
        }
        switch presentedViewController {
        case is UINavigationController:
            let navigationController = presentedViewController as! UINavigationController
            return self.topViewController(for: navigationController.viewControllers.last)
        case is UITabBarController:
            let tabBarController = presentedViewController as! UITabBarController
            return self.topViewController(for: tabBarController.selectedViewController)
        default:
            return self.topViewController(for: presentedViewController)
        }
    }
}
