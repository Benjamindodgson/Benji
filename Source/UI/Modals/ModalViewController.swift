//
//  ModalViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 6/30/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

/// A container viewcontroller to display branded alerts. Subclasses should add their own alert content.
/// Tapping on the background dismisses the controller. Automatically handles presentation and dismissal animations.
class ModalViewController: ViewController {

    // A tap area behind that modal content that will dismisses the VC
    private var dismissView = UIView()

    override func initializeViews() {
        super.initializeViews()

        self.modalPresentationStyle = .overFullScreen

        self.view.addSubview(self.dismissView)
        // Tapping on the background dismisses the VC
        self.dismissView.onTap { [unowned self] (tap) in
            self.dismiss(animated: true, completion: nil)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.dismissView.expandToSuperviewSize()
    }
}
