//
//  DailyHealthResponse.swift
//  WAYVI
//
//  Created by 이지희 on 5/29/25.
//

import Foundation

struct HealthDataResponse: Codable {
    let status: String
    let message: String
}

struct HealthReportResponse: Codable {
    let status: String
    let date: String
    let summary: String
    let stepCount: Int
    let stepCountChange: Int
    let averageRunningSpeed: Float
    let runningSpeedChange: Float
    let averageHeartRate: Int
    let heartRateChange: Int
    let averageOxygenSaturation: Int
    let averageRespiratoryRate: Int
    let averageBodyTemperature: Float
    let activeEnergyBurned: Int
    let activeEnergyChange: Int
    let warning: [String]
}
