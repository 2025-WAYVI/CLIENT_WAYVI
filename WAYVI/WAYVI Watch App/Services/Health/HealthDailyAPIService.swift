//
//  HealthDailyAPIService.swift
//  WAYVI
//
//  Created by 이지희 on 5/29/25.
//

//
//  HealthDailyAPIService.swift
//  WAYVI
//
//  Created by 이지희 on 5/29/25.
//

import Foundation

class HealthDailyAPIService {
    static let shared = HealthDailyAPIService()
    
    private let baseURL = AppConfig.baseURL

    func submitHealthData(userId: Int, request: DailyHealthRequest, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/v1/health-data/daily/\(userId)") else {
            completion(false)
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            completion(false)
            return
        }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if error != nil {
                completion(false)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                completion(false)
                return
            }

            completion(true)
        }.resume()
    }
}
