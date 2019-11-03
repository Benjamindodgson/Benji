//
//  Completeable.swift
//  Benji
//
//  Created by Benji Dodgson on 10/11/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

/// Represents an object that can be completed. For example, a name text field can be completed when a name is entered and the done
/// button is pressed. Interested parties can set a handling closure to be alerted when the completion occurs. Optionally, a closure can be
/// assigned that returns valid if the object had valid data. For example, a name text field might return true only if a full name, first and
/// last, is entered. If the getCompletionResult handler is not assigned, the object should assume the result is valid.
protocol Completable: class {

    var onDidComplete: ((Result<Void, ClientError>) -> Void)? { get set }
    var getCompletionResult: (() -> Result<Void, ClientError>)? { get set }
}

extension Completable {

    func completeWithResult() {
        let result = self.getCompletionResult?() ?? .success(())
        self.onDidComplete?(result)
    }
}