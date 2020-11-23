//
//  LaunchManager.swift
//  Benji
//
//  Created by Benji Dodgson on 1/29/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse
import Branch
import ReactiveSwift
import TMROFutures

enum LaunchStatus {
    case success(object: DeepLinkable?, token: String)
    case failed(error: ClientError?)
}

protocol LaunchManagerDelegate: class {
    func launchManager(_ manager: LaunchManager, didFinishWith status: LaunchStatus)
}

class LaunchManager {

    static let shared = LaunchManager()

    private(set) var finishedInitialFetch = false

    // Important - update this URL with your Twilio Function URL
    private let tokenURL = "https://topaz-booby-6355.twil.io/chat-token"

    // Important - this identity would be assigned by your app, for
    // instance after a user logs in
    private let url = "https://benji-backend.herokuapp.com/parse"
    private let appID = "BenjiApp"
    private let clientKey = "theStupidMasterKeyThatShouldBeSecret"

    weak var delegate: LaunchManagerDelegate?

    /// False if a branch session has already been started.
    private var shouldInitializeBranchSession = true

    func launchApp(with options: [UIApplication.LaunchOptionsKey: Any]?) {

        if !Parse.isLocalDatastoreEnabled {
            Parse.enableLocalDatastore()
        }

        if Parse.currentConfiguration == nil  {
            Parse.initialize(with: ParseClientConfiguration(block: { (configuration: ParseMutableClientConfiguration) -> Void in
                configuration.isLocalDatastoreEnabled = true
                configuration.server = self.url
                configuration.clientKey = self.clientKey
                configuration.applicationId = self.appID
            }))
        }

        if let user = User.current(), user.isAuthenticated {
            // Make sure we set this up each launch
            UserNotificationManager.shared.silentRegister(withApplication: UIApplication.shared)
        }

        // We initialize branch first so we can pass any attributes into the create user call that it might have
        self.initializeBranchIfNeeded(with: options)
            .observe(with: { (result) in
                switch result {
                case .success(let buo):
                    self.initializeUserData(with: buo)
                case .failure(_):
                    self.initializeUserData(with: nil)
                }
            })
    }

    private func initializeBranchIfNeeded(with launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Future<BranchUniversalObject?> {

        let promise = Promise<BranchUniversalObject?>()

        // There's no need to initialize the branch session multiple times per app session.
        guard self.shouldInitializeBranchSession else {
            promise.resolve(with: nil)
            return promise
        }

        let branch: Branch = Branch.getInstance()

        let notificationInfo = launchOptions?[.remoteNotification] as? [String : Any]
        if let data = notificationInfo?["data"] as? [String : Any],
            let branchLink = data["branch"] as? String {
            branch.handleDeepLink(URL(string: branchLink))
        }

        branch.initSession(launchOptions: launchOptions,
                           andRegisterDeepLinkHandlerUsingBranchUniversalObject: { (branchObject, properties, error) in

                            // Use for testing
                            //let buo = self.createTestBUO()

                            if let buo = branchObject {
                                self.updateUser(with: buo)
                                promise.resolve(with: buo)
                            } else if let buo = Branch.getInstance().getLatestReferringBranchUniversalObject() {
                                self.updateUser(with: buo)
                                promise.resolve(with: buo)
                            } else {
                                promise.resolve(with: nil)
                            }

                            if let _ = error {
                                // IMPORTANT: Allow the launch sequence to continue even if branch fails.
                                // We don't want issues with the branch api to block our app from launching.
                            } else {
                                self.shouldInitializeBranchSession = false
                            }
        })

        return promise
    }

    func updateUser(with deeplink: DeepLinkable) {
        guard let _ = User.current()?.objectId,
            let metaData = deeplink.customMetadata as? [String: Any],
            metaData.values.count > 0 else { return }

        _ = UpdateUser(attributes: metaData).makeRequest()
    }

    private func initializeUserData(with buo: BranchUniversalObject?) {
        if let identity = User.current()?.objectId {
            Branch.getInstance().setIdentity(identity)
            self.getChatToken(buo: buo)
        } else {
            self.delegate?.launchManager(self, didFinishWith: .success(object: buo, token: String()))
        }
    }

    func getChatToken(buo: BranchUniversalObject?) {
        if ChannelManager.shared.isConnected {
            self.delegate?.launchManager(self, didFinishWith: .success(object: buo, token: String()))
        } else {
            GetChatToken()
                .makeRequest()
                .observe { (result) in
                    switch result {
                    case .success(let token):
                        self.finishedInitialFetch = true
                        self.delegate?.launchManager(self, didFinishWith: .success(object: buo, token: token))
                    case .failure(_):
                        self.delegate?.launchManager(self, didFinishWith: .failed(error: ClientError.generic))
                    }
            }
        }
    }

    private func createTestBUO() -> BranchUniversalObject {
        var buo = BranchUniversalObject()
        buo.deepLinkTarget = .feed
        buo.channelId = "CH489170e8675049048bf3179e48d2a47a"
        return buo
    }

    func continueUser(activity: NSUserActivity) -> Bool {
        return Branch.getInstance().continue(activity)
    }
}
