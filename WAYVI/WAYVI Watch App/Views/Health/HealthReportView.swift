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
                        VStack(alignment: .center, spacing: 4) {
                            Label("건강 요약", systemImage: "heart.text.square")
                                .font(.title3)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            Text(report.summary)
                                .font(.body)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 8)

                        VStack(alignment: .center, spacing: 4) {
                            Label("걸음수", systemImage: "figure.walk")
                                .font(.title3)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            Text("\(report.stepCount) 걸음 (\(report.stepCountChange)% 변화)")
                                .font(.body)
                        }
                        .frame(maxWidth: .infinity)

                        VStack(alignment: .center, spacing: 4) {
                            Label("평균 심박수", systemImage: "heart.fill")
                                .font(.title3)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            Text("\(report.averageHeartRate) bpm (\(report.heartRateChange)%)")
                                .font(.body)
                        }
                        .frame(maxWidth: .infinity)

                        VStack(alignment: .center, spacing: 4) {
                            Label("평균 산소포화도", systemImage: "lungs.fill")
                                .font(.title3)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            Text("\(report.averageOxygenSaturation)%")
                                .font(.body)
                        }
                        .frame(maxWidth: .infinity)

                        VStack(alignment: .center, spacing: 4) {
                            Label("평균 체온", systemImage: "thermometer")
                                .font(.title3)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            Text("\(report.averageBodyTemperature, specifier: "%.1f")℃")
                                .font(.body)
                        }
                        .frame(maxWidth: .infinity)

                        VStack(alignment: .center, spacing: 4) {
                            Label("활동 에너지", systemImage: "flame.fill")
                                .font(.title3)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            Text("\(report.activeEnergyBurned) kcal (\(report.activeEnergyChange)%)")
                                .font(.body)
                        }
                        .frame(maxWidth: .infinity)
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
