//
//  HealthReportViewModel.swift
//  WAYVI
//
//  Created by 이지희 on 5/29/25.
//

import Foundation

class HealthReportViewModel: ObservableObject {
    @Published var report: HealthReportResponse?
    @Published var errorMessage: String?

    private let baseURL = AppConfig.baseURL
    
    func fetchHealthReport(userId: Int, date: String) {
        guard let url = URL(string: "\(baseURL)/api/v1/health-report/\(userId)/\(date)") else {
                    errorMessage = "잘못된 URL입니다."
                    return
                }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "요청 실패: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    self.errorMessage = "응답 오류"
                    return
                }

                guard let data = data else {
                    self.errorMessage = "데이터가 없습니다."
                    return
                }

                if httpResponse.statusCode == 200 {
                    do {
                        self.report = try JSONDecoder().decode(HealthReportResponse.self, from: data)
                    } catch {
                        self.errorMessage = "디코딩 실패: \(error.localizedDescription)"
                    }
                } else {
                    let message = (try? JSONDecoder().decode([String: String].self, from: data))?["message"] ?? "오류 발생"
                    self.errorMessage = "\(httpResponse.statusCode): \(message)"
                }
            }
        }.resume()
    }
}
