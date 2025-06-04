//
//  MockRoute.swift
//  WAYVI
//
//  Created by 이지희 on 6/4/25.
//

import CoreLocation

extension RouteResult {
    static var mock: RouteResult {
        return RouteResult(
            type: "FeatureCollection",
            features: [
                RouteFeature(
                    geometry: Geometry(type: "LineString", coordinates: [[126.981, 37.570]]),
                    properties: RouteProperties(
                        totalDistance: 150,
                        totalTime: 60,
//                        distance: 30,
                        description: "30미터 앞에서 직진하세요",
                        turnType: 11
                    )
                ),
                RouteFeature(
                    geometry: Geometry(type: "LineString", coordinates: [[126.982, 37.571]]),
                    properties: RouteProperties(
                        totalDistance: 200,
                        totalTime: 80,
//                        distance: 18,
                        description: "18미터 앞에서 좌회전하세요",
                        turnType: 12
                    )
                ),
                RouteFeature(
                    geometry: Geometry(type: "LineString", coordinates: [[126.982, 37.571]]),
                    properties: RouteProperties(
                        totalDistance: 200,
                        totalTime: 80,
//                        distance: 26,
                        description: "26미터 앞에서 우회전하세요",
                        turnType: 13
                    )
                ),
                RouteFeature(
                    geometry: Geometry(type: "LineString", coordinates: [[126.983, 37.572]]),
                    properties: RouteProperties(
                        totalDistance: 100,
                        totalTime: 40,
//                        distance: 0,
                        description: "목적지에 도착했습니다",
                        turnType: 201
                    )
                )
            ]
        )
    }
}
