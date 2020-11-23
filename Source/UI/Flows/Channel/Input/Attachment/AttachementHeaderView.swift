//
//  AttachementHeaderView.swift
//  Benji
//
//  Created by Benji Dodgson on 8/29/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation

class AttachementHeaderView: UICollectionReusableView {

    let photoButton = Button()
    let photoImageView = UIImageView()
    let libraryButton = Button()
    let libraryImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.initializeViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initializeViews() {

        self.addSubview(self.photoImageView)
        self.photoImageView.image = UIImage(systemName: "camera")
        self.photoImageView.contentMode = .scaleAspectFit
        self.photoImageView.tintColor = Color.lightPurple.color

        self.addSubview(self.libraryImageView)
        self.libraryImageView.image = UIImage(systemName: "square.grid.2x2")
        self.libraryImageView.tintColor = Color.lightPurple.color
        self.libraryImageView.contentMode = .scaleAspectFit

        self.addSubview(self.photoButton)
        self.addSubview(self.libraryButton)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.photoButton.expandToSuperviewWidth()
        self.photoButton.height = self.height * 0.5
        self.photoButton.pin(.top)

        self.photoImageView.squaredSize = 20
        self.photoImageView.center = self.photoButton.center

        self.libraryButton.expandToSuperviewWidth()
        self.libraryButton.height = self.height * 0.5
        self.libraryButton.pin(.bottom)

        self.libraryImageView.squaredSize = 20
        self.libraryImageView.center = self.libraryButton.center
    }
}
