//
//  LocationManager.swift
//  WAYVI
//
//  Created by 이지희 on 5/18/25.
//

import Foundation
import CoreLocation

enum LocationStatus {
    case idle
    case loading
    case success(CLLocationCoordinate2D)
    case failed(String)
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var locationStatus: LocationStatus = .idle

    override init() {
        super.init()
        
        #if targetEnvironment(simulator)
        // ✅ 시뮬레이터일 경우: 더미 좌표를 자동 주입
        let mockLocation = CLLocationCoordinate2D(latitude: 37.5615, longitude: 126.9940) // 충무로역
        self.currentLocation = mockLocation
        self.locationStatus = .success(mockLocation)
        print("🧪 시뮬레이터용 mock 위치 주입됨")
        #else
        // ✅ 실기기일 경우: 실제 위치 요청
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        start()
        #endif
    }

    func start() {
        locationStatus = .loading
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        DispatchQueue.main.async {
            self.currentLocation = location.coordinate
            self.locationStatus = .success(location.coordinate)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.locationStatus = .failed(error.localizedDescription)
            print("위치 가져오기 실패: \(error.localizedDescription)")
        }
    }
}
