//
//  RouteResult.swift
//  WAYVI
//
//  Created by 이지희 on 5/18/25.
//

struct RouteResult: Decodable, Equatable {
    let type: String
    let features: [RouteFeature]
}

struct RouteFeature: Decodable, Equatable {
    let geometry: Geometry
    let properties: RouteProperties
}

struct Geometry: Decodable, Equatable {
    let type: String
    let coordinates: [[Double]]?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)

        // Try decoding as [[Double]]
        if let nested = try? container.decode([[Double]].self, forKey: .coordinates) {
            coordinates = nested
        }
        // If it fails, try decoding as [Double] and wrap it in an array
        else if let single = try? container.decode([Double].self, forKey: .coordinates) {
            coordinates = [single]
        }
        else {
            coordinates = nil
        }
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case coordinates
    }
}

struct RouteProperties: Decodable, Equatable {
    let totalDistance: Int?
    let totalTime: Int?
    let description: String?
    let turnType: Int?
}
