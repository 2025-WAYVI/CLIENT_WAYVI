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

    func searchNearbyCategory(category: String, coordinate: CLLocationCoordinate2D, completion: @escaping (POIResult?) -> Void) {
        let encodedCategory = category.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = """
        https://apis.openapi.sk.com/tmap/pois/search/around?version=1&centerLat=\(coordinate.latitude)&centerLon=\(coordinate.longitude)&categories=\(encodedCategory)&radius=2&count=1&resCoordType=WGS84GEO
        """

        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(appKey, forHTTPHeaderField: "appKey")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let searchInfo = json["searchPoiInfo"] as? [String: Any],
                  let pois = searchInfo["pois"] as? [String: Any],
                  let poiList = pois["poi"] as? [[String: Any]],
                  let first = poiList.first,
                  let name = first["name"] as? String,
                  let radiusStr = first["radius"] as? String,
                  let distanceKm = Double(radiusStr) else {
                completion(nil)
                return
            }

            let distanceMeters = Int(distanceKm * 1000)
            completion(POIResult(name: name, distance: distanceMeters))
        }.resume()
    }
}

