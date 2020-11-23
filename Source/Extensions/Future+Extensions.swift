//
//  Future+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 7/5/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import TMROFutures
import TMROLocalization

extension Future {

    @discardableResult
    // Executes the passed in callback after this future receives its result.
    func then<NextValue>(with callback: @escaping (Value) -> Future<NextValue>) -> Future<NextValue> {

        // A promise that will be fullfilled once the callback's future is fulfilled
        let promise = Promise<NextValue>()

        // When this future gets a result, we'll execute the callback
        self.observe { result in

            switch result {
            case .success(let value):

                // Once the callback finishes its task, our original promise will be resolved or rejected
                let future: Future<NextValue> = callback(value)
                future.observe { result in
                    switch result {
                    case .success(let value):
                        promise.resolve(with: value)
                    case .failure(let error):
                        promise.reject(with: error)
                    }
                }
            case .failure(let error):
                promise.reject(with: error)
            }
        }

        return promise
    }

    // After a future is fulfilled, the transformation closure is applied to the resulting value.
    // The newly transformed value can then be use as input for another future operation.
    func transform<NextValue>(with closure: @escaping (Value) -> NextValue) -> Future<NextValue> {
        return self.then(with: { (value) in
            return Promise(value: closure(value))
        })
    }

    // Converts this future into a void future. Can be used to combine futures of differing types.
    func asVoid() -> Future<Void> {
        return self.then(with: { _ in
            return Promise(value: ())
        })
    }

    @discardableResult
    func ignoreUserInteractionEventsUntilDone(for view: UIView) -> Future<Value> {
        view.isUserInteractionEnabled = false
        self.observe { (result) in
            view.isUserInteractionEnabled = true
        }

        return self
    }

    func withResultToast(with successMessage: Localized? = nil) -> Future<Value> {
        self.observe { (result) in
            switch result {
            case .success(_):
                if let message = successMessage {
                    ToastScheduler.shared.schedule(toastType: .success(message))
                }
            case .failure(let error):
                ToastScheduler.shared.schedule(toastType: .error(error))
            }
        }

        return self
    }
}

private let waitSyncQueue = DispatchQueue(label: "When.SyncQueue", attributes: [])

func waitForAll<Value>(futures: [Future<Value>], queue: DispatchQueue? = nil) -> Future<[Value]> {
    let masterPromise = Promise<[Value]>()

    let waitQueue = queue ?? waitSyncQueue

    let totalFutures = futures.count
    var resolvedFutures = 0
    var values: [Value] = []

    if futures.isEmpty {
        masterPromise.resolve(with: values)
    } else {
        futures.forEach { promise in
            promise.observe(with: { (result) in
                waitQueue.mainSyncSafe {
                    switch result {
                    case .success(let value):
                        resolvedFutures += 1
                        values.append(value)
                        if resolvedFutures == totalFutures {
                            masterPromise.resolve(with: values)
                        }
                    case .failure(let error):
                        masterPromise.reject(with: error)
                    }
                }
            })
        }
    }

    return masterPromise
}

extension DispatchQueue {
    func mainSyncSafe(execute work: () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.sync(execute: work)
        }
    }

    func mainSyncSafe<T>(execute work: () throws -> T) rethrows -> T {
        if Thread.isMainThread {
            return try work()
        } else {
            return try DispatchQueue.main.sync(execute: work)
        }
    }
}
