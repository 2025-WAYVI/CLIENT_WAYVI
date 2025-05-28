//
//  DeviceUUIDManager.swift
//  WAYVI
//
//  Created by 이지희 on 5/28/25.
//

import Foundation

class DeviceUUIDManager {
    static let shared = DeviceUUIDManager()
    private let key = "com.wayvi.deviceUUID"

    var uuid: String {
        if let savedUUID = UserDefaults.standard.string(forKey: key) {
            return savedUUID
        } else {
            let newUUID = UUID().uuidString
            UserDefaults.standard.set(newUUID, forKey: key)
            return newUUID
        }
    }
}
