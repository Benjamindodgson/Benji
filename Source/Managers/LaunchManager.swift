//
//  LaunchManager.swift
//  Benji
//
//  Created by Benji Dodgson on 1/29/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse

class LaunchManager {

    static let shared = LaunchManager()

    // Important - update this URL with your Twilio Function URL
    private let tokenURL = "https://violet-lionfish-6641.twil.io/chat-token"

    // Important - this identity would be assigned by your app, for
    // instance after a user logs in
    private let url = "https://benji-ios.herokuapp.com/parse"
    private let appID = "benjamindodgson.Benji"
    private let clientKey = "myMasterKey"
    private let tempPhone = "2068509234"//Used for demo

    func launchApp() {
        Parse.enableLocalDatastore()

        Parse.initialize(with: ParseClientConfiguration(block: { (configuration: ParseMutableClientConfiguration) -> Void in
            configuration.server = self.url
            configuration.clientKey = self.clientKey
            configuration.applicationId = self.appID
        }))

        if let user = PFUser.current(), let identity = user.objectId {
            self.authenticateChatClient(with: identity)
        } else {
            self.createAnonymousUser()
        }
    }

    private func createAnonymousUser() {
        PFAnonymousUtils.logIn { (user, error) in
            guard let anonymousUser = user, let identifier = anonymousUser.objectId else { return }
            self.authenticateChatClient(with: identifier)
        }
    }

    func authenticateChatClient(with identity: String) {
        // Fetch Access Token from the server and initialize Chat Client - this assumes you are running
        // the PHP starter app on your local machine, as instructed in the quick start guide
        let deviceId = UIDevice.current.identifierForVendor!.uuidString
        let urlString = "\(self.tokenURL)?identity=\(identity)&device=\(deviceId)"

        TokenUtils.retrieveToken(url: urlString) { (token, identity, error) in
            if let token = token {
                //Setup Access manager with token
                // Set up Twilio Chat client
                ChannelManager.initialize(token: token)
            } else {
                print("Error retrieving token: \(error.debugDescription)")
            }
        }
    }

    func logout() {
        if let client = ChannelManager.shared.client  {
            client.delegate = nil
            client.shutdown()
        }
    }
}

fileprivate struct TokenUtils {

    static func retrieveToken(url: String, completion: @escaping (String?, String?, Error?) -> Void) {
        if let requestURL = URL(string: url) {
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let task = session.dataTask(with: requestURL, completionHandler: { (data, response, error) in
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String:String]
                        let token = json["token"]
                        let identity = json["identity"]
                        completion(token, identity, error)
                    }
                    catch let error as NSError {
                        completion(nil, nil, error)
                    }

                } else {
                    completion(nil, nil, error)
                }
            })
            task.resume()
        }
    }
}
