//
//  LoginFlowViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 8/10/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import ReactiveSwift
import PhoneNumberKit
import Parse

protocol LoginFlowable: class {
    var didComplete: (() -> Void)? { get set }
    var didClose: (() -> Void)? { get set }
}

enum LoginStep {
    case phone
    case verifyCode(PhoneNumber)
    case name
    case profilePicture
    case last
}

typealias LoginFlowableViewController = UIViewController & LoginFlowable

enum LoginFlowResult {
    case loggedIn
    case cancelled
}

protocol LoginFlowViewControllerDelegate: class {
    func loginFlowViewController(_ controller: LoginFlowViewController,
                                 finishedWith result: LoginFlowResult)
}

class LoginFlowViewController: ScrolledModalFlowViewController {

    private let navigationBar = NavigationBarView()
    private var userExists: Bool

    // A view that covers up the other view controllers when loading
    var loadingView = LoadingView()

    weak var delegate: LoginFlowViewControllerDelegate?

    init(userExists: Bool) {
        self.userExists = userExists
        super.init()

        self.topMargin = 500
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(self.navigationBar)
        self.view.addSubview(self.loadingView)

        self.handle(step: .phone)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.navigationBar.size = CGSize(width: self.view.width, height: 44)
        self.navigationBar.top = 10
        self.navigationBar.centerOnX()

        self.loadingView.size = CGSize(width: self.view.width, height: self.view.height)
        self.loadingView.bottom = self.view.height
        self.loadingView.centerOnX()
    }

    func handle(step: LoginStep) {

        let loginTitle = LocalizedString(id: "", default: "Login")
        let signUpTitle = LocalizedString(id: "", default: "Sign-up")

        switch step {
        case .phone:
            if self.userExists == true {
                self.navigationBar.titleLabel.set(text: loginTitle, alignment: .center)
            } else {
                self.navigationBar.titleLabel.set(text: signUpTitle, alignment: .center)
            }
            self.navigationBar.setLeft(UIView()) { }
            self.configurePhone()
        case .verifyCode(let phoneNumber):
            if self.userExists == true {
                self.navigationBar.titleLabel.set(text: loginTitle, alignment: .center)
            } else {
                self.navigationBar.titleLabel.set(text: signUpTitle, alignment: .center)
            }
            self.configureVerifyCode(with: phoneNumber)
        case .name:
            self.navigationBar.titleLabel.set(text: "Add Name", alignment: .center)
            self.configureNameController()
        case .profilePicture:
            self.navigationBar.titleLabel.set(text: "Add Photo", alignment: .center)
            self.configureProfilePictureController()
        case .last:
            self.navigationBar.titleLabel.set(text: "Congrats", alignment: .center)
            self.navigationBar.setLeft(UIView()) { }
            self.configureLast()
        }
    }

    private func configurePhone() {
        guard let current = PFUser.current(), current.phoneNumber == nil else {
            self.handle(step: .name)
            return
        }

        self.topMargin = UIScreen.main.bounds.height * 0.7
        let vc = LoginPhoneViewController()
        vc.didComplete = { [unowned self] phone in
            if let phoneNumber = phone {
                self.handle(step: .verifyCode(phoneNumber))
            }
        }
        self.add(controller: vc)
        self.moveForward()
        delay(0.5) {
            vc.textField.becomeFirstResponder()
        }
    }

    private func configureVerifyCode(with phoneNumber: PhoneNumber) {
        self.topMargin = UIScreen.main.bounds.height * 0.7
        let vc = LoginCodeViewController(phoneNumber: phoneNumber)
        vc.didVerifyUser = { [weak self] user in
            guard let `self` = self else { return }
            //show the last vc or the loading screen if there isnt one
            self.handle(step: .name)
        }
        self.add(controller: vc)
        self.moveForward()
        delay(0.5) {
            vc.textField.becomeFirstResponder()
        }
    }

    private func configureNameController() {

        self.topMargin = UIScreen.main.bounds.height * 0.7
        let vc = LoginNameViewController()
        vc.didAddName = { [weak self] in
            guard let `self` = self else { return }
            vc.textField.resignFirstResponder()
            self.handle(step: .profilePicture)
        }
        self.add(controller: vc)
        self.moveForward()
        delay(0.5) {
            vc.textField.becomeFirstResponder()
        }
    }

    func configureProfilePictureController() {

        self.topMargin = 300
        let vc = LoginProfilePhotoViewController()
        vc.didSavePhoto = { [weak self] in
            guard let `self` = self else { return }
            //show the last vc or the loading screen if there isnt one
            self.handle(step: .last)
        }
        self.add(controller: vc)
        self.moveForward()
        delay(0.25) {
            self.didUpdateHeight?(0, 0.25)
        }
    }

    private func configureLast() {
        self.topMargin = 500
        let controller = LoginEndingViewController()
        controller.didComplete = {
            self.fetchAllData()
        }
        self.add(controller: controller)
        self.moveForward()
    }

    private func fetchAllData() {
        guard let _ = PFUser.current() else { return }

        PFAnonymousUtils.logIn { (user, error) in
            if error != nil || user == nil {
                print("Anonymous login failed.")
            } else {
                self.finishFlow(with: .loggedIn)
            }
        }
    }

    func finishFlow(with result: LoginFlowResult) {
        self.delegate?.loginFlowViewController(self, finishedWith: result)
        self.didExit?()
    }
}
