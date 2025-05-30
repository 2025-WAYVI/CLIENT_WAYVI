//
//  LoginViewModel.swift
//  WAYVI
//
//  Created by 이지희 on 5/28/25.
//

import Foundation
import SwiftUI

class LoginViewModel: ObservableObject {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("userId") var userId: Int = -1

    private let speechManager = SpeechManager()

    func login() {
        AuthService.shared.login { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.speechManager.speak("웨이비 앱을 실행합니다.")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.userId = response.userId
                        self.isLoggedIn = true
                    }
                case .failure(let error):
                    print("로그인 실패: \(error.localizedDescription)")
                    self.speechManager.speak("로그인에 실패했습니다.")
                }
            }
        }
    }
}
