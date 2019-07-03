//
//  GradientView.swift
//  Benji
//
//  Created by Benji Dodgson on 7/3/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import QuartzCore

class GradientView: PassThroughView {
    
    private let gradient = CAGradientLayer()

    override func initializeViews() {
        self.set(backgroundColor: .clear)

        self.gradient.colors = [Color.background1.color.cgColor,
                                Color.background1.color.withAlphaComponent(0.8).cgColor,
                                Color.background1.color.withAlphaComponent(0.6).cgColor,
                                Color.background1.color.withAlphaComponent(0.4).cgColor,
                                Color.background1.color.withAlphaComponent(0).cgColor].reversed()
        self.gradient.type = .axial
        self.layer.addSublayer(self.gradient)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.gradient.frame = self.bounds
    }
}
