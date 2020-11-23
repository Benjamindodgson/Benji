//
//  DispatchQue+Extensions.swift
//  Benji
//
//  Created by Benji Dodgson on 12/25/18.
//  Copyright © 2018 Benjamin Dodgson. All rights reserved.
//

import Foundation

extension DispatchQueue {

    private class TrackedCaller: Equatable {
        private(set) weak var value: NSObject?
        var tokens: [String] = []

        init(_ value: NSObject) {
            self.value = value
        }

        static func == (lhs: TrackedCaller, rhs: TrackedCaller) -> Bool {
            return lhs.value === rhs.value
        }
    }

    private static var trackedCallers: [TrackedCaller] = []
    // Closures that aren't associated with a caller will be associated with this object.
    // Because this object is never released from memory, those closues will be called only
    // once for the entire lifetime of the app
    private static let permanentObject = NSObject()

    /**
     Executes a closure once for the lifetime of the calling object. A token is used to distinguish
     between different calls on the calling object. If no caller is passed in, the closure will
     only be executed once for the entire life of the application.
     The code is thread safe and will only execute the code once even in the
     presence of multithreaded calls. The token does not need to be globally unique. It only needs to be
     different from other "once" calls made by the caller.

     - parameter caller: The object calling the closure.
     - parameter token: A unique string (within the caller's scope) for the closure to be called
     - parameter closure: A block of code to be executed
     */
    class func once(caller: NSObject?, token: String, closure: () -> Void) {

        // Thread safety
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        let strongCaller: TrackedCaller
        // If no caller is passed in, we'll associate the closure with our static permanent object
        if let caller = caller {
            strongCaller = TrackedCaller(caller)
        } else {
            strongCaller = TrackedCaller(permanentObject)
        }

        // If the caller is already being tracked, we may not need to execute the closure
        if let trackedCaller = trackedCallers.find(strongCaller) {
            // If the caller has already tracked this token, do not execute the closure
            if trackedCaller.tokens.contains(token) {
                return
            }

            // The caller is already tracked, but not this particular token. Associate the token
            // with the caller so we don't execute it again.
            trackedCaller.tokens.append(token)
        } else {
            // Associate the token with the calling object so we don't call the closure more than once.
            strongCaller.tokens.append(token)
            trackedCallers.append(strongCaller)
        }

        // Clean up the tracked objects. Callers that have been released from memory will be removed.
        trackedCallers = trackedCallers.filter { (trackedObject) -> Bool in
            return trackedObject.value != nil
        }

        closure()
    }

    // A convenience function to execute a closure once per app load
    class func onceEver(token: String, closure: () -> Void) {
        once(caller: nil, token: token, closure: closure)
    }
}

@discardableResult func delay(_ delay: TimeInterval, _ execute: @escaping () -> ()) -> DispatchWorkItem {
    let work = DispatchWorkItem {
        execute()
    }
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: work)
    return work
}

func runMain(_ execute: @escaping () -> ()) {
    DispatchQueue.main.async {
        execute()
    }
}

func background(_ execute: @escaping () -> ()) {
    DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
        execute()
    }
}

func once(caller: NSObject?, token: String, closure: () -> Void) {
    DispatchQueue.once(caller: caller, token: token, closure: closure)
}

func onceEver(token: String, closure: () -> Void) {
    DispatchQueue.onceEver(token: token, closure: closure)
}

