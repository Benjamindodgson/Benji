//
//  AlertViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 6/30/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class AlertViewController: ViewController, PagingModalPresentable {
    var onTappedToDismiss: (() -> ())?

    let content: AlertView = UINib.loadView()
    private(set) var childViewController: UIViewController

    init(childViewController: UIViewController,
         buttons: [LoadingButton]) {

        self.childViewController = childViewController

        super.init()

        self.content.dismissHitArea.onTap { [unowned self] (tapGesture) in
            self.onTappedToDismiss?()
        }

        //self.content.configure(withDisplayable: displayable, footerButtons: footerButtons)
        self.addChild(viewController: childViewController, toView: self.content.contentView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = self.content
    }

    func configure(buttons: [LoadingButton]) {
        self.content.configure(buttons: buttons)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.childViewController.view.frame = self.content.contentView.bounds
    }
}
