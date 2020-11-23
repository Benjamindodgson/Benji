//
//  SearchBarView.swift
//  Benji
//
//  Created by Benji Dodgson on 2/1/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Lottie

protocol SearchBarDelegate: class {
    func searchBarDidBeginEditing(_ searchBar: SearchBar)
    func searchBarDidFinishEditing(_ searchBar: SearchBar)
    func searchBar(_ searchBar: SearchBar, didUpdate text: String?)
}

class SearchBar: View {

    private let animationView = AnimationView(name: "search-to-x")
    private let button = Button()
    private let textField = TextField()
    private let lineView = View()
    private var lineWidth: CGFloat = 0
    weak var delegate: SearchBarDelegate?

    var text: String? {
        return self.textField.text
    }

    private var placeholderText: String = String() {
        didSet {
            let attributed = AttributedString(self.placeholderText, color: .background3)
            self.textField.setPlaceholder(attributed: attributed)
        }
    }

    private(set) var isSearching: Bool = false {
        didSet {
            if self.isSearching {
                self.showSearch()
            } else {
                self.hideSearch()
            }
        }
    }

    override func initializeSubviews() {
        super.initializeSubviews()

        self.addSubview(self.lineView)
        self.textField.padding = .zero
        self.addSubview(self.textField)
        self.addSubview(self.animationView)
        self.addSubview(self.button)

        self.textField.alpha = 0
        self.textField.delegate = self

        self.lineView.set(backgroundColor: .white)

        self.textField.tintColor = Color.white.color
        self.textField.keyboardAppearance = .dark
        self.textField.keyboardType = .default
        self.set(backgroundColor: .clear)

        self.button.didSelect = { [unowned self] in
            self.isSearching.toggle()
        }

        self.textField.onTextChanged = { [unowned self] in
            self.delegate?.searchBar(self, didUpdate: self.text)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.button.size = CGSize(width: self.height, height: self.height)
        self.button.right = self.width
        self.button.top = 0

        self.animationView.size = CGSize(width: 26, height: 26)
        self.animationView.centerOnY()
        self.animationView.right = self.width

        self.textField.size = CGSize(width: self.width - self.button.width, height: self.height - 2)
        self.textField.top = 0
        self.textField.left = 0

        self.lineView.size = CGSize(width: self.lineWidth, height: 2)
        self.lineView.right = self.animationView.right
        self.lineView.top = self.textField.bottom
    }

    private func showSearch() {

        self.textField.becomeFirstResponder()

        self.animationView.play(fromFrame: 0, toFrame: 30, loopMode: nil) { (completed) in
            self.placeholderText = "Search"
        }

        UIView.animate(withDuration: Theme.animationDuration, delay: 0, options: .curveEaseIn, animations: {
            self.textField.alpha = 1
            self.lineWidth = self.width
            self.layoutNow()
        }, completion: nil)
    }

    private func hideSearch() {

        UIView.animate(withDuration: Theme.animationDuration) {
            self.lineWidth = 0
            self.textField.alpha = 0
            self.layoutNow()
        }

        self.animationView.play(fromFrame: 30, toFrame: 0, loopMode: nil) { (completed) in
            self.placeholderText = String()
            self.textField.text = String()
        }

        self.textField.resignFirstResponder()
    }
}

extension SearchBar: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.delegate?.searchBarDidBeginEditing(self)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegate?.searchBarDidFinishEditing(self)
    }
}
