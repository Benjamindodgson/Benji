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

    var isFinished: Bool { get }
    func toPresentable() -> DismissableVC
}

extension ViewController: Presentable {

    var isFinished: Bool { return true }
    func toPresentable() -> DismissableVC {
        return self
    }
}

class Router: NSObject, UINavigationControllerDelegate {

    private var completions: [UIViewController : () -> Void]
    unowned let navController: UINavigationController

    init(navController: UINavigationController) {
        self.navController = navController
        self.completions = [:]

        super.init()

        self.navController.delegate = self
    }

    func present(_ module: Presentable, animated: Bool) {
        self.navController.present(module.toPresentable(),
                                   animated: animated,
                                   completion: nil)
    }

    func dismiss(animated: Bool, completion: (() -> Void)?) {
        self.navController.dismiss(animated: animated, completion: completion)
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

