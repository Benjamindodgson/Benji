//
//  Routine.swift
//  Benji
//
//  Created by Martin Young on 8/13/19.
//  Copyright © 2019 Benjamin Dodgson. All rights reserved.
//

import Foundation
import Parse
import TMROFutures

enum RoutineKey: String {
    case hour
    case minute
}

final class Routine: PFObject, PFSubclassing  {

    static let currentRoutineKey = "currentRoutineKey"

    static func parseClassName() -> String {
        return String(describing: self)
    }

    var timeComponents: DateComponents {
        var components = DateComponents()
        components.hour = self.hour
        components.minute = self.minute
        return components
    }

    var date: Date? {
        var components = self.timeComponents
        let now = Date()
        components.year = now.year
        components.month = now.month
        components.day = now.day
        return Calendar.current.date(from: components)
    }
    
    var timeDescription: String {
        let hour = self.timeComponents.hour ?? 0
        let minute = self.timeComponents.minute ?? 0
        return "\(hour):\(minute)"
    }

    func create(with date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute],
                                                         from: date)
        self.set(components: components)
    }

    func create(with components: DateComponents) {
        self.set(components: components)
    }

    private func set(components: DateComponents) {
        if let hr = components.hour {
            self.hour = hr
        }

        if let min = components.minute {
            self.minute = min
        }
    }

    private(set) var hour: Int {
        get { return self.getObject(for: .hour) ?? 0 }
        set { self.setObject(for: .hour, with: newValue) }
    }

    private(set) var minute: Int {
        get { return self.getObject(for: .minute) ?? 0 }
        set { self.setObject(for: .minute, with: newValue) }
    }
}

extension Routine: Objectable {
    typealias KeyType = RoutineKey

    func getObject<Type>(for key: RoutineKey) -> Type? {
        self.object(forKey: key.rawValue) as? Type
    }

    func setObject<Type>(for key: RoutineKey, with newValue: Type) {
        self.setObject(newValue, forKey: key.rawValue)
    }

    func getRelationalObject<PFRelation>(for key: RoutineKey) -> PFRelation? {
        return self.relation(forKey: key.rawValue) as? PFRelation
    }

    func saveEventually() -> Future<Routine> {
        let promise = Promise<Routine>()

        User.current()?.routine = self
        User.current()?.saveLocalThenServer()
            .observe(with: { (result) in
                switch result {
                case .success(_):
                    RoutineManager.shared.scheduleNotification(for: self)
                    promise.resolve(with: self)
                case .failure(let error):
                    promise.reject(with: error)
                }
            })

        return promise.withResultToast(with: "Your routine successfully updated.")
    }
}
