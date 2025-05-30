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
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let report = viewModel.report {
                    Group {
                        HStack {
                            Image(systemName: "heart.text.square")
                            Text("건강 요약: \(report.summary)")
                                .font(.headline)
                        }

                        HStack {
                            Image(systemName: "figure.walk")
                            Text("걸음수: \(report.stepCount) (\(report.stepCountChange)% 변화)")
                        }

                        HStack {
                            Image(systemName: "heart.fill")
                            Text("평균 심박수: \(report.averageHeartRate)bpm (\(report.heartRateChange)%)")
                        }

                        HStack {
                            Image(systemName: "lungs.fill")
                            Text("평균 산소포화도: \(report.averageOxygenSaturation)%")
                        }

                        HStack {
                            Image(systemName: "thermometer")
                            Text("평균 체온: \(report.averageBodyTemperature, specifier: "%.1f")℃")
                        }

                        HStack {
                            Image(systemName: "flame.fill")
                            Text("활동 에너지: \(report.activeEnergyBurned)kcal (\(report.activeEnergyChange)%)")
                        }
                    }

                    if !report.warning.isEmpty {
                        Divider()
                            .padding(.top, 8)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("⚠️ 건강 주의사항 ⚠️")
                                .font(.headline)
                                .foregroundColor(.red)

                            ForEach(report.warning, id: \.self) { warning in
                                Text("- \(warning)")
                                    .foregroundColor(.red)
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
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
