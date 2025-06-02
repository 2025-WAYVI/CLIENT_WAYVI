//
//  HealthTransmissionService.swift
//  WAYVI Watch App
//
//  Created by 성호은 on 6/2/25.
//

import Foundation
import Combine
import CoreLocation

class HealthTransmissionService {
    static let shared = HealthTransmissionService()
    private var timer: Timer?
    let motion = MotionManager.shared

    private init() {}

    func start(userId: Int64) {
        stop() // 중복 실행 방지
        
        MotionManager.shared.startUpdates()

        // 5분(300초) 주기로 타이머 설정
        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
            Task {
                await self.sendHealthData(userId: userId)
            }
        }

        // 앱 실행 즉시 1회 실행
        Task {
            await self.sendHealthData(userId: userId)
        }

        // RunLoop에 등록 (Watch 앱 등에서 확실히 동작하도록)
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func sendHealthData(userId: Int64) async {
        guard let coordinate = LocationManager().currentLocation else {
            print("위치 정보 없음: Health 데이터 전송 스킵")
            return
        }

        do {
            let healthData = try await HealthKitManager.shared.fetchHealthData(with: coordinate)
            let request = RealTimeHealthRequest(
                timestamp: ISO8601DateFormatter().string(from: Date()),
                heartRate: healthData.measurements.heartRate ?? 0,
                stepCount: Int(healthData.measurements.stepCount ?? 0),
                activeEnergyBurned: Int(healthData.measurements.activeEnergy ?? 0),
                runningSpeed: [healthData.measurements.runningSpeed ?? 0],
                accel: motion.accelData,
                gyro: motion.gyroData
            )

            HealthAPIService.shared.postRealTimeHealthData(request, userId: userId) { result in
                switch result {
                case .success(let event):
                    print("[✅] Health data sent: \(event)")
                case .failure(let error):
                    print("[❌] Failed to send health data: \(error)")
                }
            }
        } catch {
            print("[❌] Health data fetch error: \(error)")
        }
    }
}
