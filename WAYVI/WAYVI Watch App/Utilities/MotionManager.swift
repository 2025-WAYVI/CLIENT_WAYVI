//
//  MotionManager.swift
//  WAYVI Watch App
//
//  Created by 성호은 on 5/28/25.
//

import Foundation
import CoreMotion

class MotionManager: ObservableObject {
    static let shared = MotionManager()
    private let motionManager = CMMotionManager()

    @Published var accelData: [Double] = [0, 0, 0]
    @Published var gyroData: [Double] = [0, 0, 0]

    private init() {}

    func startUpdates() {
        guard motionManager.isAccelerometerAvailable, motionManager.isGyroAvailable else {
            print("센서 사용 불가")
            return
        }

        motionManager.accelerometerUpdateInterval = 1.0
        motionManager.gyroUpdateInterval = 1.0

        motionManager.startAccelerometerUpdates(to: .main) { data, _ in
            if let accel = data?.acceleration {
                self.accelData = [accel.x, accel.y, accel.z]
            }
        }

        motionManager.startGyroUpdates(to: .main) { data, _ in
            if let gyro = data?.rotationRate {
                self.gyroData = [gyro.x, gyro.y, gyro.z]
            }
        }
    }

    func stopUpdates() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
    }
}
