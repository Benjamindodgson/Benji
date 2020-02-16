//
//  OnboardingViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 1/14/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import PhoneNumberKit
import Parse
import ReactiveSwift
import TMROLocalization

protocol OnboardingViewControllerDelegate: class {
    func onboardingView(_ controller: OnboardingViewController, didVerify user: PFUser)
}

class OnboardingViewController: SwitchableContentViewController<OnboardingContent> {

    lazy var reservationVC = ReservationViewController()
    lazy var phoneVC = PhoneViewController()
    lazy var codeVC = CodeViewController()
    lazy var nameVC = NameViewController()
    lazy var photoVC = PhotoViewController()
    
    unowned let delegate: OnboardingViewControllerDelegate

    init(with delegate: OnboardingViewControllerDelegate) {
        self.delegate = delegate
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func initializeViews() {
        super.initializeViews()

        self.reservationVC.onDidComplete = { [unowned self] result in
            switch result {
            case .success(_):
                self.currentContent.value = .phone(self.phoneVC)
            case .failure(let error):
                print(error)
            }
        }

        self.phoneVC.onDidComplete = { [unowned self] result in
            switch result {
            case .success(let phone):
                self.codeVC.phoneNumber = phone
                self.currentContent.value = .code(self.codeVC)
            case .failure(let error):
                print(error)
            }
        }

        self.codeVC.onDidComplete = { [unowned self] result in
            switch result {
            case .success:
                //Skip name, and photo if they have an existing account
                if let current = User.current(), current.isOnboarded {
                    self.delegate.onboardingView(self, didVerify: current)
                } else {
                    self.currentContent.value = .name(self.nameVC)
                }
            case .failure(let error):
                print(error)
            }
        }

        self.nameVC.onDidComplete = { [unowned self] result in
            switch result {
            case .success:
                self.currentContent.value = .photo(self.photoVC)
            case .failure(let error):
                print(error)
            }
        }

        self.photoVC.onDidComplete = { [unowned self] result in
            switch result {
            case .success:
                if let user = User.current() {
                    self.delegate.onboardingView(self, didVerify: user)
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    override func getInitialContent() -> OnboardingContent {
        return .phone(self.phoneVC)
    }

    override func getTitle() -> Localized {
        switch self.currentContent.value {
        case .reservation(_):
            return "Welcome!"
        case .phone(_):
            return "Welcome!"
        case .code(_):
            return "Welcome!"
        case .name(_):
            return "Welcome!"
        case .photo(let vc):
            guard let state = vc.currentState.value else { return String() }
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
    }

    override func getDescription() -> Localized {
        switch self.currentContent.value {
        case .reservation(_):
            return "Please enter your reservation code."
        case .phone(_):
            return LocalizedString(id: "",
                                   arguments: [],
                                   default: "Please verify your account using the mobile number for this device.")
        case .code(_):
            return LocalizedString(id: "",
                                   arguments: [],
                                   default: "Enter the 4 digit code from the text message.")
        case .name(_):
            return LocalizedString(id: "",
                                   arguments: [],
                                   default: "Please use your legal first and last name.")
        case .photo(_):
            return LocalizedString(id: "",
                                   arguments: [],
                                   default: "For the safety of yourself and others, we require a front facing photo. This helps ensure everyone is who they say they are. No 🤖's!")
        }
    }

    override func didSelectBackButton() {

        switch self.currentContent.value {
        case .reservation(_):
            break
        case .phone(_):
            self.currentContent.value = .reservation(self.reservationVC)
        case .code(_):
            self.currentContent.value = .phone(self.phoneVC)
        case .name(_):
            break
        case .photo(_):
            self.currentContent.value = .name(self.nameVC)
        }
    }
}
