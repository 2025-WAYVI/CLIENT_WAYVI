//
//  HealthSubmitPromptContentView.swift
//  WAYVI
//
//  Created by 이지희 on 5/29/25.
//

import SwiftUI

struct HealthSubmitPromptContentView: View {
    let userId: Int64
    let healthData: HealthData
    var onComplete: () -> Void

    var body: some View {
        let now = Date()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now)!
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        let m = healthData.measurements
        let request = DailyHealthRequest(
            timestamp: formatter.string(from: now),
            stepCount: Int(m.stepCount ?? 0),
            stepCountStartDate: formatter.string(from: startOfDay),
            stepCountEndDate: formatter.string(from: endOfDay),
            runningSpeed: [m.runningSpeed ?? 0],
            runningSpeedStartDate: formatter.string(from: startOfDay),
            runningSpeedEndDate: formatter.string(from: endOfDay),
            basalEnergyBurned: m.basalEnergy,
            activeEnergyBurned: m.activeEnergy,
            activeEnergyBurnedStartDate: formatter.string(from: startOfDay),
            activeEnergyBurnedEndDate: formatter.string(from: endOfDay),
            height: m.height,
            bodyMass: m.weight,
            oxygenSaturation: Array(repeating: 97.5, count: 8),  // 고정
            bloodPressureSystolic: m.bloodPressureSystolic,
            bloodPressureDiastolic: m.bloodPressureDiastolic,
            respiratoryRate: [18, 18, 18, 18, 19, 18, 18, 18],   // 고정
            bodyTemperature: [36.5, 36.5, 36.6, 36.6, 36.7, 36.6, 36.6, 36.7] // 고정
        )

        return HealthSubmitPromptView(
            userId: userId,
            request: request,
            onComplete: onComplete
        )
    }
}
