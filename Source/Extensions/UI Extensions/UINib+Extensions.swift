//
//  UINib+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 12/25/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension UINib {

    static func loadView<T: UIView>(withFrame frame: CGRect) -> T {
        let view: T = self.loadView()
        view.frame = frame
        return view
    }

    static func loadView<T: UIView>(inBundle bundle: Bundle? = nil,
                                    autoresizingMask: UIView.AutoresizingMask = [.flexibleWidth, .flexibleHeight]) -> T {

        let view: T = self.loadView(withName: String(describing: T.self),
                                    inBundle: bundle,
                                    autoresizingMask: autoresizingMask)
        return view
    }

    static func loadView<T: UIView>(withName name: String,
                                    inBundle bundle: Bundle? = nil,
                                    autoresizingMask: UIView.AutoresizingMask = [.flexibleWidth, .flexibleHeight]) -> T {

        let nib = UINib(nibName: name, bundle: bundle)

        let views: [Any] = nib.instantiate(withOwner: nil)
        guard views.count > 0 else {
            fatalError("Could not load \(T.self) from nib file: \(name)")
        }

        guard let view = views[0] as? T else {
            fatalError("Could not load \(T.self) from nib file: \(name)")
        }

        view.translatesAutoresizingMaskIntoConstraints = true
        view.autoresizingMask = autoresizingMask

        return view
    }
}
