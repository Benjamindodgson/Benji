//
//  NavigationBarViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 10/20/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROLocalization
import Lottie

class NavigationBarViewController: ViewController, SearchBarDelegate {

    private(set) var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private(set) var animationView = AnimationView(name: "arrow")
    private(set) var backButton = Button()
    private(set) var titleLabel = RegularBoldLabel()
    private(set) var descriptionLabel = SmallLabel()
    /// Place all views under the lineView 
    private(set) var lineView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    let scrollView = UIScrollView()
    lazy var searchBar = SearchBar()
    var showSearch: Bool = false {
        didSet {
            self.searchBar.isVisible = self.showSearch
        }
    }

    override func loadView() {
        self.view = self.scrollView
    }

    override func initializeViews() {
        super.initializeViews()

        self.view.addSubview(self.blurView)

        self.animationView.transform = CGAffineTransform(rotationAngle: halfPi * -1)
        self.view.addSubview(self.backButton)
        self.backButton.set(style: .animation(view: self.animationView))
        self.backButton.didSelect = { [unowned self] in
            self.didSelectBackButton()
        }

        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.descriptionLabel)
        self.view.addSubview(self.lineView)
        self.lineView.set(backgroundColor: .background3)

        self.searchBar.isHidden = true
        self.searchBar.delegate = self
        self.view.addSubview(self.searchBar)

        self.updateNavigationBar()
    }

    func updateNavigationBar(animateBackButton: Bool = true) {
        self.titleLabel.set(text: self.getTitle(),
                            alignment: .center,
                            stringCasing: .uppercase)
        self.descriptionLabel.set(text: self.getDescription(),
                                  color: .white,
                                  alignment: .center,
                                  stringCasing: .unchanged)

        if animateBackButton {
            delay(1.5) {
                self.animationView.play(fromFrame: 0, toFrame: 160, loopMode: nil, completion: nil)
            }
        }

        self.view.layoutNow()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.backButton.size = CGSize(width: 40, height: 40)
        self.backButton.left = Theme.contentOffset
        self.backButton.top = Theme.contentOffset

        self.titleLabel.setSize(withWidth: self.view.width * 0.8)
        self.titleLabel.centerY = self.backButton.centerY
        self.titleLabel.centerOnX()

        self.descriptionLabel.setSize(withWidth: self.view.width * 0.8)
        self.descriptionLabel.top = self.titleLabel.bottom + 20
        self.descriptionLabel.centerOnX()

        self.lineView.size = CGSize(width: self.view.width - (Theme.contentOffset * 2), height: 2)
        self.lineView.top = self.descriptionLabel.bottom + 20
        self.lineView.centerOnX()

        self.searchBar.size = CGSize(width: self.view.width - (16 * 2), height: 44)
        self.searchBar.centerOnX()
        self.searchBar.centerY = self.titleLabel.centerY

        self.blurView.expandToSuperviewSize()
    }

    // MARK: PUBLIC

    func getTitle() -> Localized {
        return LocalizedString.empty
    }

    func getDescription() -> Localized {
        return LocalizedString.empty
    }

    func didSelectBackButton() { }

    func searchBarDidBeginEditing(_ searchBar: SearchBar) {
        UIView.animate(withDuration: Theme.animationDuration) {
            self.titleLabel.alpha = 0
            self.lineView.alpha = 0
            self.descriptionLabel.alpha = 0
        }
    }

    func searchBarDidFinishEditing(_ searchBar: SearchBar) {
        UIView.animate(withDuration: Theme.animationDuration) {
            self.titleLabel.alpha = 1
            self.lineView.alpha = 1
            self.descriptionLabel.alpha = 1
        }
    }

    func searchBar(_ searchBar: SearchBar, didUpdate text: String?) {
        
    }
}
