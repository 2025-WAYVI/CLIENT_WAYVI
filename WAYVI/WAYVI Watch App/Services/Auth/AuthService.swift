//
//  AuthService.swift
//  WAYVI
//
//  Created by 이지희 on 5/28/25.
//

import Foundation

class AuthService {
    static let shared = AuthService()
    
    private let baseURL = AppConfig.baseURL

    func login(completion: @escaping (Result<LoginResponse, Error>) -> Void) {
        let uuid = DeviceUUIDManager.shared.uuid
        let requestData = LoginRequest(uuid: uuid)

        guard let url = URL(string: "\(baseURL)/api/v1/auth/uuid-login") else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1)))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(requestData)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data,
                  let decoded = try? JSONDecoder().decode(LoginResponse.self, from: data) else {
                completion(.failure(NSError(domain: "Decode error", code: -2)))
                return
            }
            completion(.success(decoded))
        }.resume()
    }
}
