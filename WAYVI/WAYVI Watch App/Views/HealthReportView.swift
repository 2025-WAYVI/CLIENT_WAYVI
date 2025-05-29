//
//  HealthReportView.swift
//  WAYVI
//
//  Created by 이지희 on 5/29/25.
//

import SwiftUI

struct HealthReportView: View {
    @StateObject private var viewModel = HealthReportViewModel()
    @AppStorage("userId") private var userId: Int = -1
    @StateObject private var speechManager = SpeechManager()

    @State private var hasSpokenWarning = false

    var body: some View {
        VStack(spacing: 12) {
            if let report = viewModel.report {
                Text("건강 요약: \(report.summary)")
                    .font(.headline)
                Text("걸음수: \(report.stepCount) (\(report.stepCountChange)% 변화)")
                Text("평균 심박수: \(report.averageHeartRate)bpm (\(report.heartRateChange)%)")
                Text("평균 산소포화도: \(report.averageOxygenSaturation)%")
                Text("평균 체온: \(report.averageBodyTemperature, specifier: "%.1f")℃")
                Text("활동 에너지: \(report.activeEnergyBurned)kcal (\(report.activeEnergyChange)%)")
                
                if !report.warning.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("⚠️ 건강 주의사항:")
                            .font(.headline)
                            .foregroundColor(.red)

                        ForEach(report.warning, id: \.self) { warning in
                            Text("- \(warning)")
                        }
                    }
                    .onAppear {
                        if !hasSpokenWarning {
                            let joined = report.warning.joined(separator: ", ")
                            speechManager.speak("\(joined)을 주의하세요")
                            hasSpokenWarning = true
                        }
                    }
                }
                
            } else if let errorMessage = viewModel.errorMessage {
                Text("에러: \(errorMessage)")
                    .foregroundColor(.red)
            } else {
                ProgressView("건강 리포트를 불러오는 중...")
                    .onAppear {
                        let today = formattedDate()
                        viewModel.fetchHealthReport(userId: userId, date: today)
                    }
            }
        }
        .padding()
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
