//
//  MainView.swift
//  WAYVI
//
//  Created by 이지희 on 5/28/25.
//

import SwiftUI

struct MainView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    init() {
        #if DEBUG
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        #endif
    }

    var body: some View {
        if isLoggedIn {
            HomeNavigationView()
        } else {
            LoginView()
        }
    }
}

// TODO: 서버 배포 후, 해당 코드로 수정
//import SwiftUI
//
//struct MainView: View {
//    @AppStorage("isLoggedIn") private var isLoggedIn = false
//
//    var body: some View {
//        if isLoggedIn {
//            HomeNavigationView()
//        } else {
//            LoginView()
//        }
//    }
//}
