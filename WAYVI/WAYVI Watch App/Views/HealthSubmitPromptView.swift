//
//  HealthSubmitPromptView.swift
//  WAYVI
//
//  Created by 이지희 on 5/29/25.
//

import SwiftUI

struct HealthSubmitPromptView: View {
    let userId: Int64
    let request: DailyHealthRequest
    var onComplete: () -> Void
    
    @StateObject private var speechManager = SpeechManager()
    @State private var didAnnounce = false
    @State private var isSubmitting = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 5) {
                Text("건강 데이터를 제출하시겠습니까?")
                    .multilineTextAlignment(.center)
                    .font(.headline)

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
