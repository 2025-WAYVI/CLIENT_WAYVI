//
//  DailyHealthRequest.swift
//  WAYVI
//
//  Created by 이지희 on 5/29/25.
//

import Foundation

struct DailyHealthRequest: Codable {
    let timestamp: String
    let stepCount: Int?
    let stepCountStartDate: String?
    let stepCountEndDate: String?

    let runningSpeed: [Double]?
    let runningSpeedStartDate: String?
    let runningSpeedEndDate: String?

    let basalEnergyBurned: Double?
    let activeEnergyBurned: Double?
    let activeEnergyBurnedStartDate: String?
    let activeEnergyBurnedEndDate: String?

    let height: Double?
    let bodyMass: Double?

    let oxygenSaturation: [Double]?
    let bloodPressureSystolic: Double?
    let bloodPressureDiastolic: Double?
    let respiratoryRate: [Double]?
    let bodyTemperature: [Double]?
}
