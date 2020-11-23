//
//  DoneToolBar.swift
//  Benji
//
//  Created by Benji Dodgson on 8/10/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class DoneToolBar: UIToolbar {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func initialize() {
        self.barStyle = UIBarStyle.default
        self.isTranslucent = true
        self.barTintColor = Color.blue.color
        self.clipsToBounds = true
        self.sizeToFit()
    }
}

class DoneBarButtonItem: UIBarButtonItem {

    convenience init(completionHandler: @escaping () -> Void) {
        let doneButton = LoadingButton()
        doneButton.set(style: .rounded(color: .clear, text: "Done"), didSelect: completionHandler)
        doneButton.sizeToFit()
        doneButton.width += 20
        doneButton.height = 100

        self.init(customView: doneButton)
    }
}
