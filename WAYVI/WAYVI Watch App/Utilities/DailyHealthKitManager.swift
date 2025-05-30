//
//  DailyHealthKitManager.swift
//  WAYVI
//
//  Created by 이지희 on 5/29/25.
//

import HealthKit
import CoreLocation

class DailyHealthKitManager {
    static let shared = DailyHealthKitManager()
    private let healthStore = HKHealthStore()

    let readTypes: Set<HKSampleType> = [
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
        HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
        HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
        HKObjectType.quantityType(forIdentifier: .bodyTemperature)!,
        HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
        HKObjectType.quantityType(forIdentifier: .height)!,
        HKObjectType.quantityType(forIdentifier: .bodyMass)!,
        HKObjectType.quantityType(forIdentifier: .runningSpeed)!,
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!
    ]

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        healthStore.requestAuthorization(toShare: [], read: readTypes, completion: { success, _ in
            completion(success)
        })
    }

    func fetchRecentSamples(completion: @escaping ([HKSample]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var allSamples: [HKSample] = []

        for type in readTypes {
            dispatchGroup.enter()
            let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.date(byAdding: .day, value: -1, to: Date()), end: Date())
            let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: 10, sortDescriptors: nil) { _, samples, _ in
                if let samples = samples {
                    allSamples.append(contentsOf: samples)
                }
                dispatchGroup.leave()
            }
            healthStore.execute(query)
        }

        dispatchGroup.notify(queue: .main) {
            completion(allSamples)
        }
    }
}
