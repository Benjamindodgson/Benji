//
//  LoadingView.swift
//  Benji
//
//  Created by Benji Dodgson on 7/5/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class LoadingView: UIView {

    private var activityIndicator = UIActivityIndicatorView(style: .large)

    init() {
        super.init(frame: CGRect())

        self.set(backgroundColor: .background1)
        self.alpha = 0

        self.addSubview(self.activityIndicator)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.activityIndicator.centerOnXAndY()
    }

    func startAnimating() {
        guard !self.activityIndicator.isAnimating else { return }

        UIView.animate(withDuration: 0.25) {
            self.alpha = 0.5
        }

        self.activityIndicator.startAnimating()
    }

    func stopAnimating() {
        UIView.animate(withDuration: 0.25) {
            self.alpha = 0
        }
        self.activityIndicator.stopAnimating()
    }
}
