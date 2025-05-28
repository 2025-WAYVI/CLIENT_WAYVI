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
    
    // HealthKit 권한 요청
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
    
    // HealthData 생성
    func fetchHealthData(with coordinate: CLLocationCoordinate2D?) async throws -> HealthData {
        let samples = try await fetchData(for: allTypes)
        return HealthData.from(healthKitData: samples, coordinate: coordinate)
    }
    
    // 샘플 데이터 쿼리
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
    
    // 최신 샘플 한 개 쿼리
    private func fetchLatestData(for type: HKQuantityType) async throws -> HKQuantitySample? {
        return try await withCheckedThrowingContinuation { continuation in
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: samples?.first as? HKQuantitySample)
            }
            healthStore.execute(query)
        }
    }

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

    // 구조요청 API 호출 메서드
    func sendEmergencyRequest(userId: Int64, event: String) {
        guard let location = LocationManager().currentLocation else {
            print("위치 정보를 가져올 수 없습니다.")
            return
        }

        let url = URL(string: "https://아직url몰라용/api/v1/emergency/request/\(userId)")!
        let formatter = ISO8601DateFormatter()
        let timestamp = formatter.string(from: Date())

        let body: [String: Any] = [
            "event": event,
            "latitude": location.latitude,
            "longitude": location.longitude,
            "timestamp": timestamp
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("구조 요청 실패: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("구조 요청 응답 코드: \(httpResponse.statusCode)")
            }

            if let data = data {
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])

                    if let json = jsonObject as? [String: Any] {
                        print("응답 내용: \(json)")

                        if let anomalyDetected = json["anomalyDetected"] as? Bool,
                           anomalyDetected,
                           let event = json["event"] as? String {

                            DispatchQueue.main.async {
                                let message: String

                                switch event {
                                case "낙상/충돌":
                                    message = "낙상 또는 충돌이 감지되었습니다."
                                case "심박 이상":
                                    message = "심박 이상이 감지되었습니다."
                                case "과로":
                                    message = "과로 징후가 감지되었습니다."
                                default:
                                    message = "건강 이상이 감지되었습니다."
                                }

                                SpeechManager().speak("\(message) 괜찮으신가요? 버튼을 눌러 응답해주세요.")
                                FallDetectionManager.shared.alertMessage = message
                                FallDetectionManager.shared.fallDetected = true
                            }
                        }
                    }
                } catch {
                    print("JSON 파싱 에러: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}

enum HealthKitError: Error {
    case notAvailable
}
