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
    
    private let baseURL = AppConfig.baseURL

    func postRealTimeHealthData(_ data: RealTimeHealthRequest, userId: Int64, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/v1/health-data/realtime/\(userId)") else {
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

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -2)))
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    
                    // 이상 징후 탐지 시 알림 처리
                    if let anomalyDetected = json["anomalyDetected"] as? Bool,
                       anomalyDetected,
                       let event = json["event"] as? String {

                        DispatchQueue.main.async {
                            let message: String

                            switch event {
                            case "낙상/충돌":
                                message = "낙상 또는 충돌이 감지되었습니다"
                            case "심박 이상":
                                message = "심박 이상이 감지되었습니다"
                            case "과로":
                                message = "과로 징후가 감지되었습니다"
                            default:
                                message = "건강 이상이 감지되었습니다"
                            }
                            
                            // 감지된 이벤트가 낙상/충돌 또는 심박 이상일 때
                            if event == "낙상/충돌" || event == "심박 이상" {
                                FallDetectionManager.shared.alertMessage = message
                                FallDetectionManager.shared.fallDetected = true
                                FallDetectionManager.shared.showEmergencyPrompt = true
                                FallDetectionManager.shared.countdownSeconds = 10

                                SpeechManager().speak("\(message) 괜찮으신가요? 10초 안에 응답하지 않으면 구조 요청을 보냅니다.")

                                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                                    if FallDetectionManager.shared.countdownSeconds <= 1 {
                                        timer.invalidate()
                                        if FallDetectionManager.shared.showEmergencyPrompt {
                                            FallDetectionManager.shared.showEmergencyPrompt = false
                                            FallDetectionManager.shared.fallDetected = false

//                                            HealthKitManager.shared.sendEmergencyRequest(
//                                                userId: userId,
//                                                event: event
//                                            )

                                            SpeechManager().speak("구조 요청이 완료되었습니다. 잠시만 기다려주세요.")
                                        }
                                    } else {
                                        FallDetectionManager.shared.countdownSeconds -= 1
                                    }
                                }
                            }

                            if event == "과로", let location = LocationManager().currentLocation {
                                FallDetectionManager.shared.alertMessage = message
                                FallDetectionManager.shared.showFatigueView = true
                            } else {
                                // 과로가 아닌 경우만 경고 + fallDetected 활성화
                                SpeechManager().speak("\(message) 괜찮으신가요? 버튼을 눌러 응답해주세요.")
                                FallDetectionManager.shared.alertMessage = message
                                FallDetectionManager.shared.fallDetected = true
                            }
                        }
                    }

                    // 정상/이상 여부와 관계없이 event 반환
                    if let event = json["event"] as? String {
                        completion(.success(event))
                    } else {
                        completion(.failure(NSError(domain: "Invalid response", code: -3)))
                    }

                } else {
                    completion(.failure(NSError(domain: "Invalid response", code: -3)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
