//
//  HealthAPIService.swift
//  WAYVI Watch App
//
//  Created by 성호은 on 5/28/25.
//

import Foundation

class HealthAPIService {
    static let shared = HealthAPIService()
    private init() {}

    func postRealTimeHealthData(_ data: RealTimeHealthRequest, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = URL(string: "https://아직url몰라용/api/v1/health-data") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(data)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "No HTTP response", code: -1)))
                return
            }

            if (200...299).contains(httpResponse.statusCode) {
                completion(.success(true))
            } else {
                completion(.failure(NSError(domain: "Server error", code: httpResponse.statusCode)))
            }
        }.resume()
    }
}
