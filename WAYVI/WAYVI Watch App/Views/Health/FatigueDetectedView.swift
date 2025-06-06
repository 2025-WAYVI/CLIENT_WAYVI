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
    @State private var showMessage = true
    @StateObject private var locationManager = LocationManager()

    @State private var nearbyCafe: POIResult? = nil
    @State private var nearbyPark: POIResult? = nil

    private let speechManager = SpeechManager()
    private let searchService = TransitSearchService()

    var body: some View {
        VStack(spacing: 16) {
            if showMessage {
                Text(message)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()
            }

            if let cafe = nearbyCafe {
                VStack {
                    Text("카페 안내")
                        .font(.headline)
                        .bold()
                    Text("\(cafe.name)")
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 4)
            }

            if let park = nearbyPark {
                VStack {
                    Text("공원 안내")
                        .font(.headline)
                        .bold()
                    Text("\(park.name)")
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 4)
            }
            
            if nearbyCafe != nil || nearbyPark != nil {
                    Button("길 안내하기") {
                        speechManager.speak("길 안내를 시작합니다.")
                        // 길 안내
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 12)
                }
        }
        .padding()
        .onAppear {
            guard !didAnnounce else { return }
            didAnnounce = true

            // 1. 과로 메시지 음성
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                speechManager.speak(message)
            }

            // 3.5초 후 메시지 제거
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                withAnimation {
                    showMessage = false
                }
            }

            // 2. 카페 / 공원 검색 및 음성 안내
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                guard let location = locationManager.currentLocation else {
                    print("⚠️ 위치 정보 없음")
                    return
                }

                searchService.searchNearbyCategory(category: "카페", coordinate: location) { cafe in
                    if let cafe = cafe {
                        let text = "가까운 휴식 장소로 카페 \(cafe.name), 약 \(cafe.distance)미터 거리에 있습니다."
                        nearbyCafe = cafe
                        speechManager.speak(text)
                    }
                }

                searchService.searchNearbyCategory(category: "공원", coordinate: location) { park in
                    if let park = park {
                        let text = "가까운 휴식 장소로 공원 \(park.name), 약 \(park.distance)미터 거리에 있습니다."
                        nearbyPark = park
                        speechManager.speak(text)
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                        dismiss()
                    }
                }
            }
        }
    }
}
