//
//  HealthSubmissionViewModel.swift
//  WAYVI
//
//  Created by 이지희 on 5/29/25.
//

import Foundation

class HealthSubmissionViewModel: ObservableObject {
    func submit(userId: Int, healthData: HealthData, completion: @escaping (Bool) -> Void) {
        let formatter = ISO8601DateFormatter()
        let now = Date()

        let startOfDay = Calendar.current.startOfDay(for: now)
        let endOfDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: now) ?? now

        let request = DailyHealthRequest(
            timestamp: formatter.string(from: now),
            stepCount: Int(healthData.measurements.stepCount ?? 0),
            stepCountStartDate: formatter.string(from: startOfDay),
            stepCountEndDate: formatter.string(from: endOfDay),
            runningSpeed: [healthData.measurements.runningSpeed ?? 0],
            runningSpeedStartDate: formatter.string(from: startOfDay),
            runningSpeedEndDate: formatter.string(from: endOfDay),
            basalEnergyBurned: healthData.measurements.basalEnergy,
            activeEnergyBurned: healthData.measurements.activeEnergy,
            activeEnergyBurnedStartDate: formatter.string(from: startOfDay),
            activeEnergyBurnedEndDate: formatter.string(from: endOfDay),
            height: healthData.measurements.height,
            bodyMass: healthData.measurements.weight,
            oxygenSaturation: Array(repeating: 97.5, count: 8),
            bloodPressureSystolic: healthData.measurements.bloodPressureSystolic,
            bloodPressureDiastolic: healthData.measurements.bloodPressureDiastolic,
            respiratoryRate: [18, 18, 18, 18, 19, 18, 18, 18],
            bodyTemperature: [36.5, 36.5, 36.6, 36.6, 36.7, 36.6, 36.6, 36.7]
        )

        HealthDailyAPIService.shared.submitHealthData(userId: userId, request: request, completion: completion)
    }
}
