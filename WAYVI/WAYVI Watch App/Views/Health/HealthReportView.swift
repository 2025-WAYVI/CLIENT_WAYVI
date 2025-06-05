//
//  HealthReportView.swift
//  WAYVI
//
//  Created by 이지희 on 5/29/25.
//

import SwiftUI

struct HealthReportView: View {
    @AppStorage("userId") private var userId: Int = -1
    
    @StateObject private var viewModel = HealthReportViewModel()
    @StateObject private var speechManager = SpeechManager()
    
    @State private var hasSpokenWarning = false
    @State private var hasSpokenSummary = false

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
                    .onAppear {
                        if !hasSpokenSummary {
                            hasSpokenSummary = true
                            let summaryText = "어제는 \(report.summary)으로 분류되었습니다. \(commentText(for: report.summary))"
                            
                            speechManager.speak(summaryText) {
                                // 첫 음성이 끝나고 나서 실행됨
                                if report.summary == "위험신호형", !report.warning.isEmpty, !hasSpokenWarning {
                                    hasSpokenWarning = true
                                    let joined = report.warning.joined(separator: ", ")
                                    speechManager.speak("\(joined)을 주의하세요")
                                }
                            }
                        }
                    }

                    if report.summary == "위험신호형" && !report.warning.isEmpty {
                        Divider().padding(.top, 8)

                        VStack(alignment: .center, spacing: 4) {
                            Text("⚠️ 건강 주의사항 ⚠️")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)

                            ForEach(report.warning, id: \.self) { warning in
                                Text(warning)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                } else if let errorMessage = viewModel.errorMessage {
                    GeometryReader { geometry in
                        ZStack {
                            Color.black.edgesIgnoringSafeArea(.all)
                            
                            VStack(spacing: 5) {
                                Text("⚠️")
                                    .font(.system(size: 50))
                                Text("에러 발생")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Text(errorMessage)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                            }
                            .padding()
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(20)
                            .frame(maxWidth: geometry.size.width * 0.9)
                            .offset(y: geometry.size.height * 5)
                            .onAppear {
                                speechManager.speak("에러가 발생했습니다. \(errorMessage)")
                            }
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                    }
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

    private func commentText(for summary: String) -> String {
        switch summary {
        case "건강 유지형":
            return "오늘도 활기찬 하루 보내세요!"
        case "저활동형":
            return "오늘은 가벼운 산책이나 스트레칭을 추천드립니다."
        case "과로주의형":
            return "오늘은 충분한 휴식과 수분섭취를 권장드립니다."
        case "위험신호형":
            return "컨디션을 확인하고 필요시 전문의 상담을 권장드립니다."
        default:
            return ""
        }
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
