//
//  NavigationDirectionHelper.swift
//  WAYVI
//
//  Created by 이지희 on 6/4/25.
//

import CoreLocation

enum NavigationDirectionHelper {
    static func directionTextAndIcon(for turnType: Int?, feature: RouteFeature) -> (String, String) {
        switch turnType {
        case 11: return ("직진하세요", "arrow.up")
        case 12: return ("좌회전하세요", "arrow.turn.left.up")
        case 13: return ("우회전하세요", "arrow.turn.right.up")
        case 14: return ("유턴하세요", "arrow.uturn.left")
        case 16: return ("8시 방향 좌회전", "arrow.left.circle")
        case 17: return ("10시 방향 좌회전", "arrow.left.circle.fill")
        case 18: return ("2시 방향 우회전", "arrow.right.circle")
        case 19: return ("4시 방향 우회전", "arrow.right.circle.fill")
        case 200: return ("출발지입니다", "play.circle")
        case 201: return ("목적지에 도착했습니다", "flag.checkered")
        case 211: return ("횡단보도를 건너세요", "figure.walk.circle")
        case 212: return ("좌측 횡단보도", "arrow.left.square")
        case 213: return ("우측 횡단보도", "arrow.right.square")
        case 125: return ("육교를 이용하세요", "building.columns")
        case 126: return ("지하보도를 이용하세요", "arrow.down.square")
        case 127: return ("계단을 이용하세요", "stairs")
        case 128: return ("경사로 진입", "arrow.down.forward.circle")
        case 218: return ("엘리베이터 이용", "arrow.up.and.down.circle")
        default:
            if let desc = feature.properties.description, !desc.isEmpty {
                return (desc, "info.circle")
            } else {
                return ("", "")
            }
        }
    }

    static func instructionText(for feature: RouteFeature, distance: CLLocationDistance) -> String {
        let turnType = feature.properties.turnType ?? 0
        let distanceText = "\(Int(distance))미터"

        let (text, _) = directionTextAndIcon(for: turnType, feature: feature)
        return text.isEmpty ? "" : "\(distanceText) \(text)"
    }
}
