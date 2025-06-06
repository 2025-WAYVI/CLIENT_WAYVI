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
        if fallManager.showEmergencyPrompt {
            // ✅ 구조 요청 화면만 단독으로 보이게
            VStack(spacing: 12) {
                Text("구조 요청까지")
                    .font(.headline)
                Text("\(fallManager.countdownSeconds)초 남음")
                    .font(.largeTitle)
                    .bold()
                Button("취소") {
                    fallManager.showEmergencyPrompt = false
                    fallManager.countdownSeconds = 10
                }
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .foregroundColor(.white)
        } else {
            // ✅ 기존 경고 알림 화면
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
                        fallManager.fallDetected = false
                        fallManager.showEmergencyPrompt = false
                        fallManager.countdownSeconds = 10
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)

                    Button("아니오") {
                        isResponseReceived = true
                        fallManager.showEmergencyPrompt = true
                        fallManager.countdownSeconds = 10
                        startEmergencyCountdown()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .onAppear {
                startResponseTimer()
            }
        }
    }

    private func startResponseTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if !isResponseReceived && !fallManager.showEmergencyPrompt {
                timerFired = true
                speechManager.speak("응답이 없습니다. 구조 요청을 보내겠습니다. 10초 안에 취소할 수 있습니다.")
                fallManager.showEmergencyPrompt = true
                fallManager.countdownSeconds = 10
                startEmergencyCountdown()
            }
        }
    }

    private func startEmergencyCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if fallManager.countdownSeconds <= 1 {
                timer.invalidate()
                if fallManager.showEmergencyPrompt {
                    fallManager.showEmergencyPrompt = false
                    fallManager.fallDetected = false

                    HealthKitManager.shared.sendEmergencyRequest(
                        userId: userId,
                        event: fallManager.alertMessage
                    )

                    speechManager.speak("구조 요청이 완료되었습니다. 잠시만 기다려주세요.")
                    dismiss()
                }
            } else {
                fallManager.countdownSeconds -= 1
            }
        }
    }
}
