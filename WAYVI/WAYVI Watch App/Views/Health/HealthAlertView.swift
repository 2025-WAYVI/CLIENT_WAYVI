//
//  HealthAlertView.swift
//  WAYVI Watch App
//
//  Created by 성호은 on 5/28/25.
//

import SwiftUI
import AVFoundation

struct HealthAlertView: View {
    var userId: Int64
    @EnvironmentObject var fallManager: FallDetectionManager
    @Environment(\.dismiss) var dismiss
    @State private var isResponseReceived = false
    @State private var timerFired = false
    private let speechManager = SpeechManager()

    var body: some View {
        VStack(spacing: 16) {
            Text(fallManager.alertMessage)
                .font(.headline)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)

            Text("괜찮으신가요?")
                .font(.subheadline)

            HStack(spacing: 20) {
                Button("예") {
                    isResponseReceived = true
                    fallManager.fallDetected = false
                }
                .buttonStyle(.borderedProminent)

                Button("아니오") {
                    isResponseReceived = true
                    fallManager.fallDetected = false
                    HealthKitManager.shared.sendEmergencyRequest(
                        userId: userId,
                        event: fallManager.alertMessage
                    )
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .onAppear {
            startResponseTimer()
        }
    }

    private func startResponseTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if !isResponseReceived {
                timerFired = true
                speechManager.speak("응답이 없습니다. 구조 요청을 보내겠습니다. 10초 안에 취소할 수 있습니다.")
                HealthKitManager.shared.sendEmergencyRequest(
                    userId: userId,
                    event: fallManager.alertMessage
                )
            }
        }
    }
}
