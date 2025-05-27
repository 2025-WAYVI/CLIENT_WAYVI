//
//  NavigationResultView.swift
//  WAYVI
//
//  Created by 이지희 on 5/18/25.
//

import SwiftUI
import AVFoundation
import WatchKit

struct NavigationResultView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var speechManager = SpeechManager()

    let result: RouteResult
    @State private var lastSpokenIndex: Int? = nil
    @State private var pendingInstructionText: String? = nil
    @State private var shouldSpeakInstruction = false

    var body: some View {
        VStack(spacing: 8) {
            if let current = locationManager.currentLocation {

                if let (index, feature) = nearestInstructionFeature(from: current),
                   let coords = feature.geometry.coordinates?.first {
                    let next = CLLocationCoordinate2D(latitude: coords[1], longitude: coords[0])
                    let distance = calculateDistance(from: current, to: next)
                    VStack(spacing: 2) {
                        Text("다음 지점까지 거리")
                            .font(.system(size: 18, weight: .bold))
                        Text("\(Int(distance)) m")
                            .font(.system(size: 30, weight: .bold))
                    }
                    .padding(.bottom, 4)

                    if let turnType = feature.properties.turnType {
                        let (text, icon) = directionTextAndIcon(for: turnType)
                        Label(text, systemImage: icon)
                            .font(.system(size: 18, weight: .bold))
                            .padding(.top, 4)

                        if distance < 20 && lastSpokenIndex != index {
                            Color.clear.frame(height: 0)
                                .onAppear {
                                    lastSpokenIndex = index
                                    pendingInstructionText = text
                                    shouldSpeakInstruction = true
                                }
                        }
                    }
                } else {
                    Text("다음 안내 지점을 찾을 수 없습니다.")
                }
            } else {
                Text("위치 정보를 가져오는 중입니다...")
            }

            Divider()
            Text("총 거리: \(result.features.first?.properties.totalDistance ?? 0)m")
            Text("총 소요시간: \(result.features.first?.properties.totalTime ?? 0)초")
        }
        .onAppear {
            locationManager.start()
        }
        .onChange(of: shouldSpeakInstruction) { _, newValue in
            if newValue, let message = pendingInstructionText {
                speechManager.speak(message)
                WKInterfaceDevice.current().play(.notification)

                // 진동 횟수 설정
                var vibrationCount = 1
                switch message {
                case "직진하세요":
                    vibrationCount = 1
                case "좌회전하세요":
                    vibrationCount = 2
                case "우회전하세요":
                    vibrationCount = 3
                case "유턴하세요":
                    vibrationCount = 4
                default:
                    vibrationCount = 1
                }

                // 반복 진동 실행
                for i in 0..<vibrationCount {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3) {
                        WKInterfaceDevice.current().play(.notification)
                    }
                }

                shouldSpeakInstruction = false
            }
        }
    }

    private func nearestInstructionFeature(from location: CLLocationCoordinate2D) -> (Int, RouteFeature)? {
        return result.features
            .enumerated()
            .filter { $0.element.properties.turnType != nil }
            .min(by: { lhs, rhs in
                guard let lhsCoord = lhs.element.geometry.coordinates?.first,
                      let rhsCoord = rhs.element.geometry.coordinates?.first else {
                    return false
                }

                let fromLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                let lhsLocation = CLLocation(latitude: lhsCoord[1], longitude: lhsCoord[0])
                let rhsLocation = CLLocation(latitude: rhsCoord[1], longitude: rhsCoord[0])

                return fromLocation.distance(from: lhsLocation) < fromLocation.distance(from: rhsLocation)
            })
    }

    private func directionTextAndIcon(for turnType: Int) -> (String, String) {
        switch turnType {
        case 1: return ("직진하세요", "arrow.up")
        case 2: return ("좌회전하세요", "arrow.turn.left.up")
        case 3: return ("우회전하세요", "arrow.turn.right.up")
        case 12: return ("유턴하세요", "arrow.uturn.left")
        case 201: return ("목적지에 도착했습니다", "flag")
        default: return ("경로를 따라 이동하세요", "location")
        }
    }

    private func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let fromLoc = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLoc = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLoc.distance(from: toLoc)
    }
}
