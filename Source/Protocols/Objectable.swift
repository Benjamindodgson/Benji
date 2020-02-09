//
//  Objectable.swift
//  Benji
//
//  Created by Benji Dodgson on 11/3/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse
import TMROFutures

enum ContainerName {
    case channel(identifier: String)
    case favorites

    var name: String {
        switch self {
        case .channel(let identifier):
            return "channel\(identifier)"
        case .favorites:
            return "favorites"
        }
    }
}

protocol Objectable: class {
    associatedtype KeyType

    func getObject<Type>(for key: KeyType) -> Type?
    func getRelationalObject<PFRelation>(for key: KeyType) -> PFRelation?
    func setObject<Type>(for key: KeyType, with newValue: Type)
    func saveLocalThenServer() -> Future<Self>
    func saveToServer() -> Future<Self>

    static func localThenNetworkQuery(for objectId: String) -> Future<Self>
    static func localThenNetworkArrayQuery(where identifiers: [String], isEqual: Bool, container: ContainerName) -> Future<[Self]>
}

extension Objectable {

    static func cachedQuery(for objectID: String) -> Future<Self> {
        return Promise<Self>()
    }

    static func cachedArrayQuery(with identifiers: [String]) -> Future<[Self]> {
        return Promise<[Self]>()
    }
}

extension Objectable where Self: PFObject {

    // Will save the object locally and push up to the server when ready
    func saveLocalThenServer() -> Future<Self> {
        let promise = Promise<Self>()
        self.saveEventually { (success, error) in
            if let error = error {
                promise.reject(with: error)
            } else {
                promise.resolve(with: self)
            }
        }
        return promise.withResultToast()
    }

    // Does not save locally but just pushes to server in the background
    func saveToServer() -> Future<Self> {
        let promise = Promise<Self>()
        self.saveInBackground { (success, error) in
            if let error = error {
                promise.reject(with: error)
            } else {
                promise.resolve(with: self)
            }
        }
        return promise.withResultToast()
    }

    static func localThenNetworkQuery(for objectId: String) -> Future<Self> {
        let promise = Promise<Self>()

        if let query = self.query() {
            query.fromPin(withName: objectId)
            query.getFirstObjectInBackground()
                .continueWith { (task) -> Any? in
                if let object = task.result as? Self {
                    promise.resolve(with: object)
                } else if let nonCacheQuery = self.query() {
                    nonCacheQuery.whereKey(ObjectKey.objectId.rawValue, equalTo: objectId)
                    nonCacheQuery.getFirstObjectInBackground { (object, error) in
                        if let nonCachedObject = object as? Self, let identifier = nonCachedObject.objectId {
                            nonCachedObject.pinInBackground(withName: identifier) { (success, error) in
                                if let error = error {
                                    promise.reject(with: error)
                                } else {
                                    promise.resolve(with: nonCachedObject)
                                }
                            }
                        } else if let error = error {
                            promise.reject(with: error)
                        } else {
                            promise.reject(with: ClientError.generic)
                        }
                    }
                } else {
                    promise.reject(with: ClientError.generic)
                }

                return nil
            }
        }

        return promise.withResultToast()
    }

    static func localThenNetworkArrayQuery(where identifiers: [String],
                                           isEqual: Bool,
                                           container: ContainerName) -> Future<[Self]> {


        let promise = Promise<[Self]>()

        if let query = self.query() {
            query.fromPin(withName: container.name)
            query.findObjectsInBackground()
                .continueWith { (task) -> Any? in
                if let objects = task.result as? [Self], !objects.isEmpty {
                    promise.resolve(with: objects)
                } else if let nonCacheQuery = self.query() {
                    if isEqual {
                        nonCacheQuery.whereKey(ObjectKey.objectId.rawValue, containedIn: identifiers)
                    } else {
                        nonCacheQuery.whereKey(ObjectKey.objectId.rawValue, notContainedIn: identifiers)
                    }
                    nonCacheQuery.findObjectsInBackground { (objects, error) in
                        PFObject.pinAll(inBackground: objects, withName: container.name) { (success, error) in
                            if let error = error {
                                promise.reject(with: error)
                            } else if let objectsForType = objects as? [Self] {
                                promise.resolve(with: objectsForType)
                            } else {
                                promise.reject(with: ClientError.generic)
                            }
                        }
                    }
                } else {
                    promise.reject(with: ClientError.generic)
                }

                return nil
            }
        }

        return promise.withResultToast()
    }
}
