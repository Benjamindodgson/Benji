//
//  Router.swift
//  Benji
//
//  Created by Benji Dodgson on 8/3/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

protocol Presentable {
    typealias DismissableVC = UIViewController & Dismissable

    func toPresentable() -> DismissableVC
    func removeFromParent()
}

extension ViewController: Presentable {

    func toPresentable() -> DismissableVC {
        return self
    }
}

class Router: NSObject, UINavigationControllerDelegate {

    var topmostViewController: UIViewController {
        return self.navController.topmostViewController()
    }

    private var completions: [UIViewController : () -> Void]
    unowned let navController: UINavigationController
    // True if the router is currently in the process of dismissing a module.
    private var isDismissing = false

    init(navController: UINavigationController) {
        self.navController = navController
        self.completions = [:]

        super.init()

        self.navController.delegate = self
    }

    // The cancel handler is called when the presented module is dimissed
    // by something other than this router.
    func present(_ module: Presentable,
                 source: UIViewController,
                 cancelHandler: (() -> Void)? = nil,
                 animated: Bool = true,
                 completion: (() -> Void)? = nil) {

        var viewController = module.toPresentable()

        viewController.dismissHandlers.append { [unowned self] in
            module.removeFromParent()

            // If this router didn't trigger the dismiss, then the module was cancelled.
            if !self.isDismissing {
                cancelHandler?()
            }
        }

        source.present(viewController,
                       animated: animated,
                       completion: completion)
    }

    func dismiss(source: UIViewController,
                 animated: Bool = true,
                 completion: (() -> Void)? = nil) {

        self.isDismissing = true
        source.dismiss(animated: animated) {
            self.isDismissing = false
            completion?()
        }
    }

    func push(_ module: Presentable,
              animated: Bool = true,
              completion: (() -> Void)? = nil) {

        let controller = module.toPresentable()
        if let completion = completion {
            completions[controller] = completion
        }
        self.navController.pushViewController(controller, animated: animated)
    }

    func popModule(animated: Bool) {
        guard let controller = self.navController.popViewController(animated: animated) else {
            return
        }

        self.runCompletion(for: controller)
    }

    func setRootModule(_ module: Presentable, animated: Bool) {
        self.navController.setViewControllers([module.toPresentable()], animated: animated)
    }

    fileprivate func runCompletion(for controller: UIViewController) {
        guard let completion = completions[controller] else {
            return
        }
        completion()
        self.completions.removeValue(forKey: controller)
    }

    // MARK: UINavigationControllerDelegate

    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        //Add custom presentation classes here.
        return nil
    }

    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {

        // Ensure the view controller is popping
        guard let poppedViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
            !navigationController.viewControllers.contains(poppedViewController) else {
                return
        }

        self.runCompletion(for: poppedViewController)
    }
}

