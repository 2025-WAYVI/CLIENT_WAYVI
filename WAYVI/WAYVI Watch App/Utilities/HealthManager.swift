//
//  HealthManager.swift
//  WAYVI Watch App
//
//  Created by 성호은 on 5/19/25.
//

import Foundation
import HealthKit
import CoreLocation
import Combine

class HealthKitManager: NSObject, ObservableObject {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()
    
    @Published var isAuthorized = false
    
    // 수집할 데이터 유형들
    private lazy var allTypes: Set<HKSampleType> = {
        let types: [HKSampleType] = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .runningSpeed)!,
            HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .height)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
            HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
            HKObjectType.quantityType(forIdentifier: .bodyTemperature)!
        ]
        return Set(types)
    }()
    
    private override init() {
        super.init()
    }
    
    // MARK: - HealthKit 권한 요청
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit 사용 불가")
            throw HealthKitError.notAvailable
        }
        
        print("HealthKit 권한 요청 중...")
        let typesToRead = allTypes
        
        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
        DispatchQueue.main.async {
            self.isAuthorized = true
        }
        print("HealthKit 권한 허용됨")
    }
    
    // MARK: - HealthData 생성
    func fetchHealthData(with coordinate: CLLocationCoordinate2D?) async throws -> HealthData {
        let samples = try await fetchData(for: allTypes)
        return HealthData.from(healthKitData: samples, coordinate: coordinate)
    }
    
    // MARK: - 샘플 데이터 쿼리
    private func fetchData(for types: Set<HKSampleType>) async throws -> [HKSample] {
        var allSamples: [HKSample] = []
        
        for type in types {
            guard let quantityType = type as? HKQuantityType else { continue }
            
            if let sample = try await fetchLatestData(for: quantityType) {
                allSamples.append(sample)
                let value = sample.quantity.doubleValue(for: preferredUnit(for: quantityType))
                print("\(quantityType.identifier): \(value) at \(sample.startDate)")
            } else {
                print("데이터 없음: \(quantityType.identifier)")
            }
        }
        
        return allSamples
    }
    
    // MARK: - 최신 샘플 한 개 쿼리
    private func fetchLatestData(for type: HKQuantityType) async throws -> HKQuantitySample? {
        return try await withCheckedThrowingContinuation { continuation in
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                let sample = samples?.first as? HKQuantitySample
                continuation.resume(returning: sample)
            }
            healthStore.execute(query)
        }
    }

    // MARK: - 단위 설정
    private func preferredUnit(for type: HKQuantityType) -> HKUnit {
        switch type.identifier {
        case HKQuantityTypeIdentifier.stepCount.rawValue:
            return .count()
        case HKQuantityTypeIdentifier.heartRate.rawValue:
            return HKUnit.count().unitDivided(by: .minute())
        case HKQuantityTypeIdentifier.oxygenSaturation.rawValue:
            return .percent()
        case HKQuantityTypeIdentifier.bodyTemperature.rawValue:
            return .degreeCelsius()
        case HKQuantityTypeIdentifier.bloodPressureSystolic.rawValue,
             HKQuantityTypeIdentifier.bloodPressureDiastolic.rawValue:
            return .millimeterOfMercury()
        case HKQuantityTypeIdentifier.respiratoryRate.rawValue:
            return HKUnit.count().unitDivided(by: .minute())
        case HKQuantityTypeIdentifier.height.rawValue:
            return .meterUnit(with: .centi)
        case HKQuantityTypeIdentifier.bodyMass.rawValue:
            return .gramUnit(with: .kilo)
        case HKQuantityTypeIdentifier.runningSpeed.rawValue:
            return HKUnit.meter().unitDivided(by: .second())
        case HKQuantityTypeIdentifier.activeEnergyBurned.rawValue,
             HKQuantityTypeIdentifier.basalEnergyBurned.rawValue:
            return .kilocalorie()
        default:
            return .count()
        }
    }
}

// MARK: - 오류 정의
enum HealthKitError: Error {
    case notAvailable
}
