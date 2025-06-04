//
//  MockNavigationView.swift
//  WAYVI
//
//  Created by 이지희 on 6/4/25.
//

import Foundation
import Combine
import CoreLocation

class MockNavigationViewModel: ObservableObject {
    @Published var currentFeature: RouteFeature?
    private var timer: Timer?
    private var index = 0
    private let features = RouteResult.mock.features
    private let speechManager = SpeechManager()

    func startMockNavigation() {
        index = 0
        currentFeature = features[index]
        speakCurrent()

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.index += 1
            if self.index < self.features.count {
                self.currentFeature = self.features[self.index]
                self.speakCurrent()
            } else {
                self.timer?.invalidate()
            }
        }
    }

    func stopMockNavigation() {
        timer?.invalidate()
        timer = nil
    }

    private func speakCurrent() {
        if let description = currentFeature?.properties.description {
            speechManager.speak(description)
        }
    }

    func calculateDistance(to: CLLocationCoordinate2D) -> CLLocationDistance {
        return 1 /*CLLocationDistance(currentFeature?.properties.distance ?? 0)*/
    }
}
