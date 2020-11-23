//
//  Promise.swift
//  TMROFutures
//
//  Created by Benji Dodgson on 11/4/19.
//  Copyright © 2019 Tomorrow Ideas. All rights reserved.
//

import Foundation

// A future value that can be fulfilled. Promises are a subclass of futures that allow you to set the
// result or pass in an error, thus alerting any observers.
public class Promise<Value>: Future<Value> {

    public init(value: Value? = nil) {
        super.init()

        // If the value was already known at the time the promise was constructed,
        // we can report the value directly
        if let value = value {
            self.result = Result.success(value)
        }
    }

    public init(error: Error) {
        super.init()
        self.result = Result.failure(error)
    }

    public func resolve(with value: Value) {
        self.result = .success(value)
    }

    public func reject(with error: Error) {
        self.result = .failure(error)
    }
}
