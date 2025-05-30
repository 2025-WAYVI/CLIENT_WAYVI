//
//  HealthSubmitPromptView.swift
//  WAYVI
//
//  Created by 이지희 on 5/29/25.
//

import SwiftUI

struct HealthSubmitPromptView: View {
    let userId: Int
    let request: DailyHealthRequest
    var onComplete: () -> Void
    
    @StateObject private var speechManager = SpeechManager()
    @State private var didAnnounce = false
    @State private var isSubmitting = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Text("건강 데이터를 제출하시겠습니까?")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 22, weight: .bold))
                    .padding(.top, -10)

                Button("제출") {
                    submit()
                }
                .buttonStyle(.borderedProminent)
                .disabled(isSubmitting)

                Button("취소") {
                    speechManager.speak("건강 데이터 제출을 취소했습니다.")
                    onComplete()
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .onAppear {
            if !didAnnounce {
                speechManager.speak("목적지에 도착했습니다. 건강 데이터를 제출하시겠습니까?")
                didAnnounce = true
            }
        }
    }
    
    private func submit() {
        isSubmitting = true
        HealthDailyAPIService.shared.submitHealthData(userId: Int(userId), request: request) { success in
            DispatchQueue.main.async {
                isSubmitting = false
                if success {
                    speechManager.speak("건강 데이터를 성공적으로 제출했습니다.")
                } else {
                    speechManager.speak("건강 데이터 제출에 실패했습니다.")
                }
                onComplete()
            }
        }
    }
}

#Preview {
    HealthSubmitPromptView(
        userId: 1,
        request: DailyHealthRequest(
            timestamp: "2025-05-29T12:00:00Z",
            stepCount: 8000,
            stepCountStartDate: "2025-05-29T00:00:00Z",
            stepCountEndDate: "2025-05-29T23:59:59Z",
            runningSpeed: [5.6],
            runningSpeedStartDate: "2025-05-29T00:00:00Z",
            runningSpeedEndDate: "2025-05-29T23:59:59Z",
            basalEnergyBurned: 1200.0,
            activeEnergyBurned: 300.0,
            activeEnergyBurnedStartDate: "2025-05-29T00:00:00Z",
            activeEnergyBurnedEndDate: "2025-05-29T23:59:59Z",
            height: 165.0,
            bodyMass: 55.0,
            oxygenSaturation: Array(repeating: 97.5, count: 8),
            bloodPressureSystolic: 110,
            bloodPressureDiastolic: 70,
            respiratoryRate: [18, 18, 18, 18, 19, 18, 18, 18],
            bodyTemperature: [36.5, 36.6, 36.6, 36.7, 36.5, 36.6, 36.7, 36.6]
        ),
        onComplete: {}
    )
}
