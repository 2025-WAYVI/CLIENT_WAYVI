//
//  LoginViewModel.swift
//  WAYVI
//
//  Created by 이지희 on 5/28/25.
//

import Foundation
import SwiftUI

import Foundation
import SwiftUI

class LoginViewModel: ObservableObject {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @Published var userId: Int64 = 0
    private let speechManager = SpeechManager()

    func login() {
        speechManager.speak("로그인을 시도합니다.")

        // 테스트용 로그인 성공 처리
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.userId = 1
            self.isLoggedIn = true
            self.speechManager.speak("웨이비 앱을 실행합니다.")
        }
    }
}

// TODO: 서버 도메인 연결 후 해당 코드로 교체
//import Foundation
//import SwiftUI
//
//class LoginViewModel: ObservableObject {
//    @AppStorage("isLoggedIn") private var isLoggedIn = false
//    @Published var userId: Int64 = 0
//
//    private let speechManager = SpeechManager()
//
//    func login() {
//        AuthService.shared.login { result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let response):
//                    self.userId = Int64(response.userId) ?? 0
//                    self.isLoggedIn = true
//                    self.speechManager.speak("웨이비 앱을 실행합니다.")
//                case .failure(let error):
//                    print("로그인 실패: \(error.localizedDescription)")
//                    self.speechManager.speak("로그인에 실패했습니다.")
//                }
//            }
//        }
//    }
//}
