//
//  TransitSearchResultView.swift
//  WAYVI Watch App
//
//  Created by 성호은 on 6/6/25.
//

import Foundation
import SwiftUICore
import SwiftUI

struct TransitSearchResultView: View {
    let poi: POIResult
    let category: String
    let onNavigate: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("\(category) 안내")
                .font(.headline)

            Text("\(poi.name)")
                .multilineTextAlignment(.center)
                .lineLimit(nil) // 줄 수 제한 없음
                .fixedSize(horizontal: false, vertical: true) // 세로로 확장 가능

            Button("길 안내하기") {
                onNavigate()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 4)
        }
        .padding()
        .padding()
    }
}
