//
//  MainView.swift
//  WAYVI
//
//  Created by 이지희 on 5/28/25.
//


import SwiftUI

struct MainView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false

    var body: some View {
        if isLoggedIn {
            HomeNavigationView()
        } else {
            LoginView()
        }
    }
}
