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
        let mockLocation = CLLocationCoordinate2D(latitude: 37.56141113963326, longitude: 126.99555016821692) // 충무로역
        self.currentLocation = mockLocation
        self.locationStatus = .success(mockLocation)
        print("🧪 시뮬레이터용 mock 위치 주입됨: \(mockLocation.latitude), \(mockLocation.longitude)")
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
        print("📍 위치 업데이트 시작 요청됨")
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            print("⚠️ 위치 정보 배열이 비어 있음")
            return
        }

        let coordinate = location.coordinate
        DispatchQueue.main.async {
            self.currentLocation = coordinate
            self.locationStatus = .success(coordinate)
            print("✅ 위치 업데이트 수신됨: \(coordinate.latitude), \(coordinate.longitude)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let nsError = error as NSError
        DispatchQueue.main.async {
            self.locationStatus = .failed(error.localizedDescription)
            print("❌ 위치 가져오기 실패: \(error.localizedDescription) (code: \(nsError.code))")
        }
    }
}
