//
//  ScrolledModalPresentable.swift
//  Benji
//
//  Created by Benji Dodgson on 8/13/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

protocol ScrolledModalControllerPresentable where Self : UIViewController {
    var topMargin: CGFloat { get }
    var scrollView: UIScrollView? { get }
    var scrollingEnabled: Bool { get }
    var didDismiss: (() -> Void)? { get set }
    var didUpdateHeight: ((CGRect, TimeInterval, UIView.AnimationCurve) -> ())? { get set }
}
