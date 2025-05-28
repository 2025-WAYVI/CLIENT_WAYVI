//
//  TransitSelectionView.swift
//  WAYVI Watch App
//
//  Created by 성호은 on 5/19/25.
//

import SwiftUI
import CoreLocation

struct TransitSelectionView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var speechManager = SpeechManager()
    private let searchService = TransitSearchService()

    var body: some View {
        VStack(spacing: 12) {
            Button(action: {
                speakNearbyPOI(category: "버스정류장")
            }) {
                Label("버스 정류장 안내", systemImage: "bus")
            }

            Button(action: {
                speakNearbyPOI(category: "지하철역")
            }) {
                Label("지하철역 안내", systemImage: "tram.fill")
            }
        }
        .padding()
        .onAppear {
            locationManager.start()
        }
    }

    private func speakNearbyPOI(category: String) {
        guard let location = locationManager.currentLocation else {
            speechManager.speak("현재 위치를 확인할 수 없습니다.")
            return
        }

        searchService.searchNearbyCategory(category: category, coordinate: location) { result in
            DispatchQueue.main.async {
                if let poi = result {
                    speechManager.speak("근처 \(poi.distance)m 안에 \(poi.name)이 있습니다.")
                } else {
                    speechManager.speak("근처에 \(category) 정보를 찾을 수 없습니다.")
                }
            }
        }
    }
}
