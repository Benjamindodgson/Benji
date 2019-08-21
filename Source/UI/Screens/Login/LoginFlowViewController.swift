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
    var didComplete: () -> Void { get set }
    var didClose: () -> Void { get set }
}

enum LoginStep {
    case intro(LoginFlowableViewController)
    case phone
    case verifyCode(PhoneNumber)
    case name
    case profilePicture
    case last(LoginFlowableViewController)
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
    private let introVC: (LoginFlowableViewController)?
    private let endingVC: (LoginFlowableViewController)?
    private var userExists: Bool

    // A view that covers up the other view controllers when loading
    var loadingView = LoadingView()

    weak var delegate: LoginFlowViewControllerDelegate?

    init(introVC: (LoginFlowableViewController)?,
         endingVC: (LoginFlowableViewController)?,
         userExists: Bool) {

        self.introVC = introVC
        self.endingVC = endingVC
        self.userExists = userExists
        super.init()

        self.topMargin = UIScreen.main.bounds.height * 0.7
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(self.navigationBar)

        if let vc = self.introVC {
            self.handle(step: .intro(vc))
        } else {
            self.handle(step: .phone)
        }

        self.view.addSubview(self.loadingView)
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
        case .intro(let controller):
            self.configureIntro(with: controller)
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
        case .last(let controller):
            self.navigationBar.titleLabel.set(text: "Congrats")
            self.navigationBar.setLeft(UIView()) { }
            self.configureLast(with: controller)
        }
    }

    private func configureIntro(with controller: LoginFlowableViewController) {
        controller.didComplete = { [unowned self] in
            guard let current = PFUser.current(), current.isAuthenticated else {
                // If the user is already logged in, refetch all their data
                self.fetchAllData()
                return
            }

            self.handle(step: .phone)
            self.moveForward()
        }
        controller.didClose = { [unowned self] in
            self.finishFlow(with: .cancelled)
        }
        self.add(controller: controller)
    }

    private func configurePhone() {
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
        let vc = LoginProfilePhotoViewController()
        vc.didSavePhoto = { [weak self] in
            guard let `self` = self else { return }
            //show the last vc or the loading screen if there isnt one
            if let finalVC = self.endingVC {
                self.handle(step: .last(finalVC))
            } else {
                self.fetchAllData()
            }
        }
        self.add(controller: vc)
        self.moveForward()
    }

    private func configureLast(with controller: LoginFlowableViewController) {
        controller.didComplete = {

        }
        self.add(controller: controller)
        self.moveForward()
    }

    private func fetchAllData() {
//        self.loadingView.startAnimating()

//        FetchAllUserData.begin(completion: { [weak self] (tomorrowError) in
//            guard let `self` = self else { return }
//
//            self.loadingView.stopAnimating()
            self.finishFlow(with: .loggedIn)
//        })
    }

    func finishFlow(with result: LoginFlowResult) {
        self.delegate?.loginFlowViewController(self, finishedWith: result)
        self.didExit?()
    }
}
