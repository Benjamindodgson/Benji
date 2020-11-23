//
//  CenterNavigationController.swift
//  Benji
//
//  Created by Benji Dodgson on 12/27/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

class RootNavigationController: NavigationController, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.set(backgroundColor: .background1)
        self.delegate = self
        self.setNavigationBarHidden(true, animated: false)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(rotationDidChange),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)

    }

    @objc func rotationDidChange() { }

    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return nil 
    }
}
