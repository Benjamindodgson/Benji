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

    private let color: Color

    init(with color: Color = .background1) {
        self.color = color
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func initializeSubviews() {
        super.initializeSubviews()
        
        self.set(backgroundColor: .clear)

        self.gradient.colors = [self.color.color.cgColor,
                                self.color.color.cgColor,
                                self.color.color.withAlphaComponent(0.9).cgColor,
                                self.color.color.withAlphaComponent(0.8).cgColor,
                                self.color.color.withAlphaComponent(0.6).cgColor,
                                self.color.color.withAlphaComponent(0).cgColor].reversed()
        self.gradient.type = .axial
        self.layer.addSublayer(self.gradient)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.gradient.frame = self.bounds
    }
}
