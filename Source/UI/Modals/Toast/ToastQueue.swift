//
//  ToastQueue.swift
//  Benji
//
//  Created by Benji Dodgson on 7/23/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation

class ToastQueue {
    static let shared = ToastQueue()

    private let toaster = TomorrowToaster()
    private(set) var allViewed: [String] = []
    private var scheduled: [Toast] = []

    func add(toast: Toast) {
        if !self.scheduled.isEmpty || self.toaster.isPresenting {
            self.scheduled.append(toast)
            self.scheduled = self.scheduled.sorted { (lhs, rhs) -> Bool in
                return lhs.priority > rhs.priority
            }
        } else {
            self.present(toast: toast)
        }
    }

    private func present(toast: Toast) {
        guard !self.allViewed.contains(toast.id) else {
            self.scheduled.remove(object: toast)
            if let next = self.scheduled.last {
                self.present(toast: next)
            }
            return
        }

        self.toaster.add(toast: toast)
        self.allViewed.append(toast.id)

        self.toaster.didDismiss = { _ in
            if let nextToast = self.scheduled.last  {
                self.present(toast: nextToast)
                self.scheduled.remove(object: nextToast)
            }
        }
    }
}

fileprivate class TomorrowToaster {

    var items: [ToastView] = []
    var didDismiss: (String) -> Void = {_ in }
    var isPresenting: Bool = false

    func add(toast: Toast) {

        let toastView = ToastView()
        toastView.configure(toast: toast)

        if let current = self.items.first {
            current.dismiss()
        }
        self.items.append(toastView)

        if self.items.count == 1 {
            self.isPresenting = true
            toastView.reveal()
        }

        toastView.didDismiss = { [unowned self] in
            self.didDismiss(toastView: toastView)
            self.didDismiss(toast.id)
        }

        toastView.didTap = { [unowned self] in
            self.reportButtonTap(for: toast)
        }
    }

    func didDismiss(toastView: ToastView) {
        toastView.removeFromSuperview()
        self.items.remove(object: toastView)
        self.isPresenting = false

        if !self.items.isEmpty, let nextView = self.items[safe: 0] {
            nextView.reveal()
        }
    }

    private func reportButtonTap(for toast: Toast) {
        let eventName = toast.analyticsID + ".Tapped"
        self.reportEvent(for: eventName)
    }

    private func reportEvent(for eventName: String) {
        //Add reporting here
    }
}
