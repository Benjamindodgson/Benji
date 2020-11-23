//
//  AvatarView.swift
//  Benji
//
//  Created by Benji Dodgson on 6/23/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class AvatarView: DisplayableImageView {

    // MARK: - Properties

    private let selectionImpact = UIImpactFeedbackGenerator()

    var didSelect: CompletionOptional = nil {
        didSet {
            guard let didSelect = self.didSelect else { return }
            
            self.gestureRecognizers?.forEach({ (recognizer) in
                self.removeGestureRecognizer(recognizer)
            })

            self.onTap { (tap) in
                didSelect()
            }
        }
    }

    var borderColor: Color = .purple {
        didSet {
            self.setBorder(color: self.borderColor)
        }
    }

    var initials: String? {
        didSet {
            self.setImageFrom(initials: self.initials)
        }
    }

    var placeholderFont: UIFont = FontType.regularBold.font {
        didSet {
            self.setImageFrom(initials: self.initials)
        }
    }

    var placeholderTextColor: UIColor = Color.purple.color {
        didSet {
            self.setImageFrom(initials: self.initials)
        }
    }

    var fontMinimumScaleFactor: CGFloat = 0.5
    var adjustsFontSizeToFitWidth = true

    private var minimumFontSize: CGFloat {
        return self.placeholderFont.pointSize * self.fontMinimumScaleFactor
    }

    private var radius: CGFloat?

    // MARK: - Overridden Properties
    override var frame: CGRect {
        didSet {
            self.setCorner(radius: self.radius)
        }
    }

    override var bounds: CGRect {
        didSet {
            self.setCorner(radius: self.radius)
        }
    }

    // MARK: - Initializers

    override init() {
        super.init()
        self.prepareView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.prepareView()
    }

    private func setImageFrom(initials: String?) {
        guard let initials = initials else { return }
        self.imageView.image = self.getImageFrom(initials: initials)
    }

    func getSize(for height: CGFloat) -> CGSize {
        return CGSize(width: height * 0.74, height: height)
    }

    func setSize(for height: CGFloat) {
        self.size = self.getSize(for: height)
    }

    private func getImageFrom(initials: String) -> UIImage {
        let width = self.frame.width
        let height = self.frame.height
        if width == 0 || height == 0 { return UIImage() }
        var font = self.placeholderFont

        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        let context = UIGraphicsGetCurrentContext()!

        //// Text Drawing
        let textRect = self.calculateTextRect(outerViewWidth: width, outerViewHeight: height)
        let initialsText = NSAttributedString(string: initials, attributes: [.font: font,
                                                                             .foregroundColor: Color.purple.color])
        if self.adjustsFontSizeToFitWidth,
            initialsText.width(considering: textRect.height) > textRect.width {
            let newFontSize = self.calculateFontSize(text: initials,
                                                     font: font,
                                                     width: textRect.width,
                                                     height: textRect.height)
            font = self.placeholderFont.withSize(newFontSize)
        }

        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .center
        let textFontAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font,
                                                                 NSAttributedString.Key.foregroundColor: self.placeholderTextColor,
                                                                 NSAttributedString.Key.paragraphStyle: textStyle]

        let textTextHeight: CGFloat = initials.boundingRect(with: CGSize(width: textRect.width, height: CGFloat.infinity),
                                                            options: .usesLineFragmentOrigin,
                                                            attributes: textFontAttributes,
                                                            context: nil).height
        context.saveGState()
        context.clip(to: textRect)

        let rect = CGRect(x: textRect.minX,
                          y: textRect.minY + (textRect.height - textTextHeight) / 2,
                          width: textRect.width,
                          height: textTextHeight)
        initials.draw(in: rect, withAttributes: textFontAttributes)
        context.restoreGState()

        guard let renderedImage = UIGraphicsGetImageFromCurrentImageContext() else { assertionFailure("Could not create image from context"); return UIImage() }

        return renderedImage
    }

    /**
     Recursively find the biggest size to fit the text with a given width and height
     */
    private func calculateFontSize(text: String,
                                   font: UIFont,
                                   width: CGFloat,
                                   height: CGFloat) -> CGFloat {

        let attributedText = NSAttributedString(string: text, attributes: [.font: font])
        if attributedText.width(considering: height) > width {
            let newFont = font.withSize(font.pointSize - 1)
            if newFont.pointSize > self.minimumFontSize {
                return font.pointSize
            } else {
                return calculateFontSize(text: text, font: newFont, width: width, height: height)
            }
        }
        return font.pointSize
    }

    /**
     Calculates the inner circle's width.
     Note: Assumes corner radius cannot be more than width/2 (this creates circle).
     */
    private func calculateTextRect(outerViewWidth: CGFloat, outerViewHeight: CGFloat) -> CGRect {
        guard outerViewWidth > 0 else {
            return CGRect.zero
        }
        let shortEdge = min(outerViewHeight, outerViewWidth)
        // Converts degree to radian degree and calculate the
        // Assumes, it is a perfect circle based on the shorter part of ellipsoid
        // calculate a rectangle
        let w = shortEdge * sin(CGFloat(45).degreesToRadians) * 2
        let h = shortEdge * cos(CGFloat(45).degreesToRadians) * 2
        let startX = (outerViewWidth - w)/2
        let startY = (outerViewHeight - h)/2
        // In case the font exactly fits to the region, put 2 pixel both left and right
        return CGRect(x: startX+2, y: startY, width: w-4, height: h)
    }

    private func prepareView() {
        self.imageView.contentMode = .scaleAspectFill
        self.layer.masksToBounds = true
        self.clipsToBounds = true
        self.setCorner(radius: 5)
        self.layer.borderColor = self.borderColor.color.cgColor
        self.layer.borderWidth = 3
        self.backgroundColor = self.borderColor.color.withAlphaComponent(0.4)
    }

    // MARK: - Open setters

    func set(avatar: Avatar) {
        self.displayable = avatar
        guard avatar.image == nil, avatar.userObjectID == nil else { return }
        self.initials = avatar.initials
        self.layoutNow()
    }

    func setCorner(radius: CGFloat?) {
        guard let radius = radius else {
            //if corner radius not set default to Circle
            let cornerRadius = min(frame.width, frame.height)
            self.layer.cornerRadius = cornerRadius/2
            return
        }
        self.radius = radius
        self.layer.cornerRadius = radius
    }

    func setBorder(color: Color) {
        self.layer.borderColor = color.color.cgColor
        self.layer.borderWidth = 2
    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let touch = touches.first, let view = touch.view, let _ = self.didSelect {
            self.selectionImpact.impactOccurred()
            view.scaleDown()
        }
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if let touch = touches.first, let view = touch.view, let _ = self.didSelect {
            view.scaleUp()
        }
    }

    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        if let touch = touches.first, let view = touch.view, let _ = self.didSelect {
            view.scaleUp()
        }
    }
}

fileprivate extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
