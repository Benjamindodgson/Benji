//
//  AlertButton.swift
//  Benji
//
//  Created by Benji Dodgson on 6/30/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Lottie

class LoadingButton: Button {

    private let shouldRound: Bool = true
    var canShowLoading: Bool = true

//    var isLoading: Bool = false {
//        didSet {
//            runMain {
//                guard self.canShowLoading else { return }
//
////                if self.isLoading {
////                    self.showLoading()
////                } else {
////                    self.hideLoading()
////                }
//
//                self.isUserInteractionEnabled = !self.isLoading
//                self.isEnabled = !self.isLoading
//            }
//        }
//    }

    init() {
        super.init(frame: .zero)
        self.initializeViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initializeViews()
    }

    private func initializeViews() {

        // Disable when the keyboard is shown
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)

        self.addSubview(self.animationView)
        self.animationView.contentMode = .scaleAspectFit
        self.animationView.loopMode = .loop
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.animationView.size = CGSize(width: 18, height: 18)
        self.animationView.centerOnXAndY()
    }

    @objc func keyboardWillShow(notification: Notification) {
        self.isEnabled = false
    }

    @objc func keyboardWillHide(notification: Notification) {
        self.isEnabled = true
    }
}
