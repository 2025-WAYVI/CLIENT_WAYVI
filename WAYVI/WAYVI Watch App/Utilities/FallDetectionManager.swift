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
    
    // 응답 대기 상태 추가
    @Published var showEmergencyPrompt: Bool = false
    @Published var countdownSeconds: Int = 10

    public init() {}
}
