//
//  LoginIntroViewController.swift
//  Benji
//
//  Created by Benji Dodgson on 8/19/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class LoginIntroViewController: LoginFlowableViewController {
    var didComplete: (() -> Void)? 
    var didClose: (() -> Void)?
}
