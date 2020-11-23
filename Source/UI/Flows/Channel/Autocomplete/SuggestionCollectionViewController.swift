//
//  AutocompleteViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 10/22/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class SuggestionCollectionViewController: CollectionViewController<SuggestionCell, SuggestionCollectionViewManager>, Completable {

    var onDidComplete: ((Result<Void, Error>) -> Void)?
    var getCompletionResult: (() -> Result<Void, ClientError>)?

    private var blurView = UIVisualEffectView(effect: nil)

    private var suggestionCollectionView: SuggestionCollectionView? {
        return self.collectionView as? SuggestionCollectionView
    }

    weak var textField: TextField?
    weak var textView: TextView?

    init(parentController: UIViewController) {

        let collectionView = CollectionView(layout: UICollectionViewFlowLayout())
        super.init(with: collectionView)
        parentController.addChild(self)
    }

    convenience init(with parentController: UIViewController,
                     textField: TextField) {
        self.init(parentController: parentController)
        self.textField = textField
    }

    convenience init(with parentController: UIViewController,
                     textView: TextView) {
        self.init(parentController: parentController)
        self.textView = textView
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func initializeViews() {
        super.initializeViews()

        self.view.addSubview(self.blurView)
        self.view.addSubview(self.collectionView)

        self.textField?.onTextChanged = { [unowned self] in
            guard let tf = self.textField else { return }
            self.textDidChange(with: tf.text)
        }

        self.showAccessoryView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.blurView.frame = self.view.bounds
        self.collectionView.frame = self.view.bounds
    }

    func loadSuggestions(for text: String?) {
//        guard ContactsManager.shared.isContactsAccessAllowed else { return }
//        self.manager.filterText = text
    }

    func configure(with keyboardAppearance: UIKeyboardAppearance) {

        self.collectionViewManager.keyboardAppearance = keyboardAppearance
        switch keyboardAppearance {
        case .light:
            self.blurView.effect = UIBlurEffect(style: .prominent)
        case .dark, .default:
            self.blurView.effect = UIBlurEffect(style: .dark)
        @unknown default:
            break
        }

        self.collectionView.reloadData()
    }

    func textDidChange(with text: String?) {
        self.showAccessoryView()
        self.loadSuggestions(for: text)
    }

    func showAccessoryView() {
        guard self.textField?.inputAccessoryView == nil else { return }
        self.configure(with: self.textField?.keyboardAppearance ?? .dark)
        self.textField?.inputAccessoryView = self.view
        self.textField?.reloadInputViews()
    }

    private func hideAccessoryView() {
        self.textField?.inputAccessoryView = nil
        self.textField?.reloadInputViews()
    }

}
