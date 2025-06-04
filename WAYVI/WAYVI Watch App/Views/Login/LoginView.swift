//
//  LoginView.swift
//  WAYVI
//
//  Created by 이지희 on 5/28/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @StateObject private var speechManager = SpeechManager()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack(spacing: 30) {
            Text("WayVi")
                .font(.custom("Manjari", size: 40).weight(.bold))
                .tracking(-1.5)
                .lineSpacing(250)
                .multilineTextAlignment(.center)

            Button(action: {
                viewModel.login()
            }) {
                Text("로그인")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .controlSize(.large)
            .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .multilineTextAlignment(.center)
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                speechManager.speak("하단의 로그인 버튼을 눌러 로그인해주세요.")
            }
        }
    }
}
