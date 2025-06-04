//
//  MockNavigationView.swift
//  WAYVI
//
//  Created by 이지희 on 6/4/25.
//

import SwiftUI
import CoreLocation
import AVFoundation
import WatchKit

struct MockNavigationView: View {
    @StateObject private var viewModel = MockNavigationViewModel()

    var body: some View {
        VStack(spacing: 8) {
            if let feature = viewModel.currentFeature,
               let coords = feature.geometry.coordinates?.first {

                let next = CLLocationCoordinate2D(latitude: coords[1], longitude: coords[0])
                let distance = viewModel.calculateDistance(to: next)

                let (text, icon) = NavigationDirectionHelper.directionTextAndIcon(for: feature.properties.turnType, feature: feature)

                VStack(spacing: 2) {
                    Text("다음 지점까지 거리")
                        .font(.system(size: 18, weight: .bold))
                    Text("\(Int(distance)) m")
                        .font(.system(size: 30, weight: .bold))
                    Divider()
                        .frame(height: 1)
                        .background(Color.gray.opacity(0.6))
                        .padding(.vertical, 8)
                    if !text.isEmpty && !icon.isEmpty {
                        Label {
                            Text(text)
                                .font(.system(size: 18, weight: .bold))
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                        } icon: {
                            Image(systemName: icon)
                        }
                        .padding(.top, 4)
                    } else if !text.isEmpty {
                        Text(text)
                            .font(.system(size: 18, weight: .bold))
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.top, 4)
                    }
                }
            } else {
                Text("길 안내 준비 중...")
            }
        }
        .onAppear {
            viewModel.startMockNavigation()
        }
        .onDisappear {
            viewModel.stopMockNavigation()
        }
    }
}
