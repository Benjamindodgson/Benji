//
//  Connection+CloudCalls.swift
//  Benji
//
//  Created by Benji Dodgson on 2/11/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse
import TMROFutures
import PhoneNumberKit

struct UpdateConnection: CloudFunction {

    var connection: Connection
    var status: Connection.Status

    func makeRequest() -> Future<Void> {
        let promise = Promise<Void>()

        PFCloud.callFunction(inBackground: "updateConnection",
                             withParameters: ["connectionId": self.connection.objectId!,
                                              "status": self.status.rawValue]) { (object, error) in
                                                if let error = error {
                                                    SessionManager.shared.handleParse(error: error)
                                                    promise.reject(with: error)
                                                } else {
                                                    promise.resolve(with: ())
                                                }
        }

        return promise.withResultToast()
    }
}

struct GetAllConnections: CloudFunction {

    enum Direction: String {
        case incoming
        case outgoing
        case all
    }

    var direction: Direction = .all

    func makeRequest() -> Future<[Connection]> {
        let promise = Promise<[Connection]>()
        PFCloud.callFunction(inBackground: "getConnections", withParameters: nil) { (object, error) in
            if let error = error {
                SessionManager.shared.handleParse(error: error)
                promise.reject(with: error)
            } else if let dict = object as? [String: [Connection]] {
                var all: [Connection] = []

                switch self.direction {
                case .incoming:
                    if let incoming = dict["incoming"] {
                        all = incoming
                    }
                case .outgoing:
                    if let outgoing = dict["outgoing"] {
                        all = outgoing
                    }
                case .all:
                    if let incoming = dict["incoming"] {
                        all.append(contentsOf: incoming)
                    }
                    if let outgoing = dict["outgoing"] {
                        all.append(contentsOf: outgoing)
                    }
                }
                promise.resolve(with: all)
            } else {
                promise.resolve(with: [])
            }
        }

        return promise.withResultToast()
    }
}


