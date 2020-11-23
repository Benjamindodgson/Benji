//
//  HomeTabView.swift
//  Benji
//
//  Created by Benji Dodgson on 12/17/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class HomeTabView: View {

    private(set) var profileItem = ImageViewButton()
    private(set) var feedItem = ImageViewButton()
    private(set) var channelsItem = ImageViewButton()
    private(set) var lineView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private let flashLightView = View()

    private let selectionFeedback = UIImpactFeedbackGenerator(style: .light)
    private var indicatorCenterX: CGFloat?

    var currentContent: HomeContent?
    
    override func initializeSubviews() {
        super.initializeSubviews()

        self.set(backgroundColor: .background2)

        self.addSubview(self.lineView)
        self.addSubview(self.flashLightView)
        self.flashLightView.set(backgroundColor: .purple)
        self.addSubview(self.profileItem)
        self.addSubview(self.feedItem)
        self.addSubview(self.channelsItem)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.lineView.expandToSuperviewWidth()
        self.lineView.height = 1
        self.lineView.pin(.top)

        let itemWidth = self.width * 0.33
        let itemSize = CGSize(width: itemWidth, height: 60)
        self.profileItem.size = itemSize
        self.profileItem.top = 0
        self.profileItem.left = 0

        self.feedItem.size = itemSize
        self.feedItem.top = 0
        self.feedItem.left = self.profileItem.right

        self.channelsItem.size = itemSize
        self.channelsItem.top = 0
        self.channelsItem.left = self.feedItem.right

        self.flashLightView.size = CGSize(width: itemWidth * 0.35, height: 2)
        self.flashLightView.bottom = itemSize.height

        guard self.indicatorCenterX == nil else { return }

        self.flashLightView.centerX = self.feedItem.centerX
    }

    func updateTabItems(for contentType: HomeContent) {
        self.selectionFeedback.impactOccurred()
        self.currentContent = contentType
        self.animateIndicator(for: contentType)
    }

    private func animateIndicator(for contentType: HomeContent) {
        let newCenterX: CGFloat

        switch contentType {
        case .feed(_):
            newCenterX = self.feedItem.centerX
        case .channels(_):
            newCenterX = self.channelsItem.centerX
        case .profile(_):
            newCenterX = self.profileItem.centerX
        }

        UIView.animateKeyframes(withDuration: 0.5, delay: 0.0, options: [.calculationModeLinear], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.33) {
                self.flashLightView.transform = CGAffineTransform(scaleX: 0.2, y: 1.0)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.33, relativeDuration: 0.33) {
                self.flashLightView.centerX = newCenterX
                self.setNeedsLayout()
            }
            UIView.addKeyframe(withRelativeStartTime: 0.66, relativeDuration: 0.33) {
                self.flashLightView.transform = .identity
                self.updateButtons(for: contentType)
            }
        }) { _ in
            self.indicatorCenterX = newCenterX
        }
    }

    private func updateButtons(for contentType: HomeContent) {
        switch contentType {
        case .feed:
            self.feedItem.imageView.image = UIImage(systemName: "square.stack.fill")
            self.feedItem.imageView.tintColor = Color.purple.color
            self.profileItem.imageView.image = UIImage(systemName: "person.crop.circle")
            self.profileItem.imageView.tintColor = Color.white.color
            self.channelsItem.imageView.image = UIImage(systemName: "bubble.left.and.bubble.right")
            self.channelsItem.imageView.tintColor = Color.white.color
        case .channels:
            self.feedItem.imageView.image = UIImage(systemName: "square.stack")
            self.feedItem.imageView.tintColor = Color.white.color
            self.profileItem.imageView.image = UIImage(systemName: "person.crop.circle")
            self.profileItem.imageView.tintColor = Color.white.color
            self.channelsItem.imageView.image = UIImage(systemName: "bubble.left.and.bubble.right.fill")
            self.channelsItem.imageView.tintColor = Color.purple.color
        case .profile:
            self.feedItem.imageView.image = UIImage(systemName: "square.stack")
            self.feedItem.imageView.tintColor = Color.white.color
            self.profileItem.imageView.image = UIImage(systemName: "person.crop.circle.fill")
            self.profileItem.imageView.tintColor = Color.purple.color
            self.channelsItem.imageView.image = UIImage(systemName: "bubble.left.and.bubble.right")
            self.channelsItem.imageView.tintColor = Color.white.color
        }
    }
}
