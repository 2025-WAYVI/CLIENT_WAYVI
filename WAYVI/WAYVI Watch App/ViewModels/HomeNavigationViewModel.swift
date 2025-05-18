//
//  HomeNavigationViewModel.swift
//  WAYVI
//
//  Created by 이지희 on 5/18/25.
//

import Foundation

class ModeNavigationViewModel: ObservableObject {
    @Published var navigationStarted = false
    @Published var showTransitInfo = false

    func startNavigation() {
        navigationStarted = true
        // 길 안내 로직 처리
    }

    func showTransit() {
        showTransitInfo = true
        // 대중교통 정보 호출
    }
}
