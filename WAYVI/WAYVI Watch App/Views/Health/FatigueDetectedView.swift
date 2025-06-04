//
//  FatigueDetectedView.swift
//  WAYVI Watch App
//
//  Created by 성호은 on 6/4/25.
//

import SwiftUI
import AVFoundation
import CoreLocation

struct FatigueDetectedView: View {
    let message: String

    @Environment(\.dismiss) private var dismiss
    @State private var didAnnounce = false
    @StateObject private var locationManager = LocationManager()

    private let speechManager = SpeechManager()
    private let searchService = TransitSearchService()

    var body: some View {
        VStack(spacing: 16) {
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
        }
        .onAppear {
            // 최초 1회만 실행되도록 막음
            guard !didAnnounce else { return }
            didAnnounce = true

            // 1. 과로 메시지 안내
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                speechManager.speak(message)
            }

            // 2. 위치 기반 카페/공원 안내
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                guard let location = locationManager.currentLocation else {
                    print("⚠️ 위치 정보 없음")
                    return
                }

                searchService.searchNearbyCategory(category: "카페", coordinate: location) { cafe in
                    if let cafe = cafe {
                        let text = "가까운 휴식 장소로 카페 \(cafe.name), 약 \(cafe.distance)미터 거리에 있습니다."
                        speechManager.speak(text)
                    }
                }

                searchService.searchNearbyCategory(category: "공원", coordinate: location) { park in
                    if let park = park {
                        let text = "가까운 휴식 장소로 공원 \(park.name), 약 \(park.distance)미터 거리에 있습니다."
                        speechManager.speak(text)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        dismiss()
                    }
                }
            }
        }
    }
}
