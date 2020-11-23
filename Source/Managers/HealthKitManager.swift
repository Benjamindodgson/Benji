//
//  HealthKitManager.swift
//  Benji
//
//  Created by Benji Dodgson on 4/11/20.
//  Copyright © 2020 Benjamin Dodgson. All rights reserved.
//

import Foundation
import HealthKit
import TMROFutures

class HealthKitManager: NSObject {

    static let shared = HealthKitManager()
    private let store = HKHealthStore()

    private let allReadTypes = Set([HKObjectType.categoryType(forIdentifier: .mindfulSession)!, HKObjectType.quantityType(forIdentifier: .heartRate)!])
    private let allSetTypes = Set([HKObjectType.categoryType(forIdentifier: .mindfulSession)!])

    func requestAuthorization(completion: @escaping CompletionHandler) {
        self.store.requestAuthorization(toShare: self.allSetTypes, read: self.allReadTypes) { (success, error) in
            completion(success, error)
        }
    }

    func saveMindfullAnalysis(startTime: Date, endTime: Date, completion: @escaping CompletionHandler) {
        if let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession) {

            // Create a mindful session with the given start and end time
            let mindfullSample = HKCategorySample(type: mindfulType,
                                                  value: 0,
                                                  start: startTime,
                                                  end: endTime)

            // Save it to the health store
            self.store.save(mindfullSample, withCompletion: { (success, error) -> Void in
                completion(success, error)
            })
        } else {
            completion(false, ClientError.generic)
        }
    }
}

