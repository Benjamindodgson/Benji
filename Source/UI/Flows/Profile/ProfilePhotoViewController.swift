//
//  ProfilePhotoViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 2/1/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROLocalization

enum PhotoContentType: Switchable {

    case photo(PhotoViewController)

    var viewController: UIViewController & Sizeable {
        switch self {
        case .photo(let vc):
            return vc
        }
    }

    var shouldShowBackButton: Bool {
        return false
    }
}

protocol ProfilePhotoViewControllerDelegate: class {
    func profilePhotoViewControllerDidFinish(_ controller: ProfilePhotoViewController)
}

class ProfilePhotoViewController: SwitchableContentViewController<PhotoContentType> {

    lazy var photoVC = PhotoViewController()

    unowned let delegate: ProfilePhotoViewControllerDelegate

    private var currentState: PhotoState? {
        return self.photoVC.currentState.value
    }

    init(with delegate: ProfilePhotoViewControllerDelegate) {
        self.delegate = delegate
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func initializeViews() {
        super.initializeViews()

        self.photoVC.view.set(backgroundColor: .clear)

        self.photoVC.onDidComplete = { [unowned self] result in
            switch result {
            case .success:
                self.delegate.profilePhotoViewControllerDidFinish(self)
            case .failure(let error):
                print(error)
            }
        }

        self.photoVC.currentState.producer
            .skipRepeats()
            .on(value:  { [unowned self] (state) in
                self.updateNavigationBar(animateBackButton: false)
            }).start()
    }

    override func getInitialContent() -> PhotoContentType {
        return .photo(self.photoVC)
    }

    override func getTitle() -> Localized {
        guard let state = self.currentState else { return LocalizedString.empty }

        switch state {
        case .initial:
            return LocalizedString(id: "",
                                   arguments: [],
                                   default: "Verify Indentity")
        case .scan:
            return LocalizedString(id: "",
                                   arguments: [],
                                   default: "Scanning...")
        case .capture:
            return LocalizedString(id: "",
                                   arguments: [],
                                   default: "Identity Verified")
        case .error:
            return LocalizedString(id: "",
                                   arguments: [],
                                   default: "Error!")
        case .finish:
            return LocalizedString.empty
        }
    }

    override func getDescription() -> Localized {
        return LocalizedString(id: "",
                               arguments: [],
                               default: "For the safety of yourself and others, we require a front facing photo. This helps ensure everyone is who they say they are. No 🤖's!")
    }
}
