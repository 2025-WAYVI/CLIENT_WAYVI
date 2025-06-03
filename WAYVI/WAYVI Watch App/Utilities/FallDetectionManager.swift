//
//  FallDetectionManager.swift
//  WAYVI Watch App
//
//  Created by 성호은 on 5/28/25.
//

import Foundation
import Combine

class FallDetectionManager: ObservableObject {
    static let shared = FallDetectionManager()

    @Published var fallDetected: Bool = false
    @Published var alertMessage: String = ""
    @Published var showFatigueView: Bool = false

    public init() {}
}
