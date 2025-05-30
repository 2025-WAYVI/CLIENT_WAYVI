//
//  NavigationViewModel.swift
//  WAYVI
//
//  Created by 이지희 on 5/18/25.
//

import Foundation
import CoreLocation

class NavigationViewModel: ObservableObject {
    @Published var destinationName: String = ""
    @Published var isLoading = false
    @Published var routeResult: RouteResult? = nil
    @Published var showResult = false
    
    private let tmapService = TMapService()

    func searchRoute(currentLocation: CLLocationCoordinate2D, destination: String) {
        destinationName = destination
        isLoading = true

        // 목적지명을 기반으로 좌표를 먼저 검색 (POI API)
        tmapService.searchPOI(keyword: destination) { poiCoordinate in
            print("📍 POI 검색 결과: \(String(describing: poiCoordinate))")
            guard let poi = poiCoordinate else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }

            // 경로 요청
            self.tmapService.requestPedestrianRoute(
                start: currentLocation,
                end: poi,
                startName: "현재위치",
                endName: destination
            ) { result in
                DispatchQueue.main.async {
                    self.routeResult = result
                    self.isLoading = false
                    self.showResult = (result != nil)
                }
            }
        }
    }
}
