//
//  TMapService.swift
//  WAYVI
//
//  Created by 이지희 on 5/18/25.
//

import Foundation
import CoreLocation

class TMapService {
    private let appKey: String

    init() {
        self.appKey = Bundle.main.infoDictionary?["TMAP_APP_KEY"] as? String ?? ""
    }

    // 목적지 위경도 검색 요청
    func searchPOI(keyword: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        guard let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://apis.openapi.sk.com/tmap/pois?version=1&searchKeyword=\(encodedKeyword)&resCoordType=WGS84GEO&reqCoordType=WGS84GEO&count=1") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(appKey, forHTTPHeaderField: "appKey")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else {
                print("❌ 응답 없음")
                completion(nil)
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                if let searchInfo = json?["searchPoiInfo"] as? [String: Any],
                   let pois = searchInfo["pois"] as? [String: Any],
                   let poiList = pois["poi"] as? [[String: Any]],
                   let first = poiList.first,
                   let latStr = first["frontLat"] as? String,
                   let lonStr = first["frontLon"] as? String,
                   let lat = Double(latStr),
                   let lon = Double(lonStr) {
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    print("📍 좌표 추출 성공: \(coordinate)")
                    completion(coordinate)
                    return
                } else {
                    print("📡 POI 응답 파싱 실패 (구조가 예상과 다름)")
                    completion(nil)
                }
            } catch {
                print("❌ JSON 파싱 에러: \(error)")
                completion(nil)
            }
        }.resume()
    }

    // 보행자 경로 안내 요청
    func requestPedestrianRoute(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D, startName: String, endName: String, completion: @escaping (RouteResult?) -> Void) {
        guard let url = URL(string: "https://apis.openapi.sk.com/tmap/routes/pedestrian?version=1") else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(appKey, forHTTPHeaderField: "appKey")

        let body: [String: Any] = [
            "startX": start.longitude,
            "startY": start.latitude,
            "endX": end.longitude,
            "endY": end.latitude,
            "startName": startName,
            "endName": endName,
            "searchOption": "10",
            "sort": "index"
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else {
                completion(nil)
                return
            }

            print("📦 raw pedestrian route 응답: \(String(data: data, encoding: .utf8) ?? "nil")")

            let result = try? JSONDecoder().decode(RouteResult.self, from: data)
            completion(result)
        }.resume()
    }
}
