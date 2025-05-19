//
//  TransitSearchService.swift
//  WAYVI Watch App
//
//  Created by 성호은 on 5/19/25.
//

import Foundation
import CoreLocation

class TransitSearchService {
    private let appKey = Bundle.main.infoDictionary?["TMAP_APP_KEY"] as? String ?? ""

    func searchNearbyPOI(keyword: String, coordinate: CLLocationCoordinate2D, completion: @escaping (POIResult?) -> Void) {
        let urlString = "https://apis.openapi.sk.com/tmap/pois?version=1&searchKeyword=\(keyword)&centerLat=\(coordinate.latitude)&centerLon=\(coordinate.longitude)&count=1&resCoordType=WGS84GEO"

        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURL) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(appKey, forHTTPHeaderField: "appKey")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let searchInfo = json["searchPoiInfo"] as? [String: Any],
                  let pois = searchInfo["pois"] as? [String: Any],
                  let poiList = pois["poi"] as? [[String: Any]],
                  let first = poiList.first,
                  let name = first["name"] as? String,
                  let distanceStr = first["distance"] as? String,
                  let distance = Int(distanceStr) else {
                completion(nil)
                return
            }

            completion(POIResult(name: name, distance: distance))
        }.resume()
    }
}

