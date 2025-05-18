//
//  HomeNavigationView.swift
//  WAYVI
//
//  Created by 이지희 on 5/18/25.
//

import SwiftUI
import WatchKit
import AVFoundation

struct HomeNavigationView: View {
    @StateObject private var viewModel = NavigationViewModel()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var speechManager = SpeechManager()
    @State private var showResultView = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                if viewModel.isLoading {
                    ProgressView("길을 찾는 중...")
                } else {
                    Button(action: {
                        presentSpeechInput()
                    }) {
                        Label("길 안내 시작", systemImage: "location.fill")
                    }
                    .buttonStyle(.borderedProminent)

                    Button(action: {
                        // TODO: 대중교통 안내 기능 구현
                    }) {
                        Label("대중교통 안내", systemImage: "bus")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .navigationDestination(isPresented: $showResultView) {
                if let result = viewModel.routeResult {
                    NavigationResultView(result: result)
                } else {
                    Text("경로 정보를 불러오지 못했습니다.")
                }
            }
            .onChange(of: viewModel.routeResult, initial: false) { oldValue, newValue in
                if newValue != nil {
                    showResultView = true
                }
            }
        }
    }

    private func presentSpeechInput() {
        speechManager.speak("상단의 버튼을 눌러 목적지를 말씀해주세요.")
        
        WKExtension.shared().visibleInterfaceController?.presentTextInputController(
            withSuggestions: ["동국대학교", "충무로역", "동대입구역"],
            allowedInputMode: .plain
        ) { results in
            if let destination = results?.first as? String,
               let location = locationManager.currentLocation {
                viewModel.searchRoute(currentLocation: location, destination: destination)
            }
        }
    }
}
