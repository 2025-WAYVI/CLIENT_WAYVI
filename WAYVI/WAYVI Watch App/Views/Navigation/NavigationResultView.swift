import SwiftUI
import AVFoundation
import WatchKit
import CoreLocation
import CoreMotion

struct NavigationResultView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var speechManager = SpeechManager()
    private let motionManager = CMMotionManager()

    let result: RouteResult
    let countdownTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @State private var lastSpokenIndex: Int? = nil
    @State private var pendingInstructionText: String? = nil
    @State private var shouldSpeakInstruction = false

    @State private var previousLocation: CLLocationCoordinate2D? = nil
    @State private var stationaryCounter: Int = 0
    @State private var showStayPrompt = false
    @State private var showEmergencyPrompt = false
    @State private var emergencyCountdown: Int = 10
    @State private var isMotionZero: Bool = false
    @State private var showHealthSubmitPrompt = false
    @State private var shouldNavigateToHome = false
    
    @State private var healthData: HealthData? = nil
    @AppStorage("userId") private var userId: Int = -1
    
    @StateObject private var submissionViewModel = HealthSubmissionViewModel()
        
    var body: some View {
        VStack(spacing: 8) {
            Group {
                if let current = locationManager.currentLocation {
                    navigationInfoSection(current: current)
                } else {
                    Text("위치 정보를 가져오는 중입니다...")
                }
            }
        }
        .onChange(of: locationManager.currentLocation) { _, current in
            guard let current = current else { return }
            handleLocationUpdate(current)
        }
        .onChange(of: shouldSpeakInstruction) { _, newValue in
            if newValue, let message = pendingInstructionText {
                triggerSpeech(for: message)
            }
        }
        .alert("계속 길안내를 받으시겠습니까?", isPresented: $showStayPrompt) {
            Button("예") {
                stationaryCounter = 0
                showStayPrompt = false
            }
            Button("아니오") {
                showStayPrompt = false
                showEmergencyPrompt = true
                speechManager.speak("응답이 없습니다. 구조요청을 보내겠습니다. 10초 안에 취소할 수 있습니다")
                startEmergencyCountdown()
            }
        }
        .overlay(
            Group {
                if showEmergencyPrompt {
                    VStack(spacing: 12) {
                        Text("구조 요청까지")
                            .font(.headline)
                        Text("\(emergencyCountdown)초 남음")
                            .font(.largeTitle)
                            .bold()
                        Button("취소") {
                            showEmergencyPrompt = false
                            emergencyCountdown = 10
                            stationaryCounter = 0
                        }
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
                    .foregroundColor(.white)
                }
            }
        )
        .sheet(isPresented: $showHealthSubmitPrompt) {
            Group {
                if let healthData = healthData {
                    HealthSubmitPromptContentView(
                        userId: userId,
                        healthData: healthData,
                        onComplete: {
                            showHealthSubmitPrompt = false
                            shouldNavigateToHome = true
                        }
                    )
                } else {
                    Text("건강 데이터를 불러오는 중입니다.")
                }
            }
        }
    }

    @ViewBuilder
    private func navigationInfoSection(current: CLLocationCoordinate2D) -> some View {
        if let (index, feature) = nearestInstructionFeature(from: current),
           let coords = feature.geometry.coordinates?.first {

            let next = CLLocationCoordinate2D(latitude: coords[1], longitude: coords[0])
            let distance = calculateDistance(from: current, to: next)

            let turnType = feature.properties.turnType
            let (text, icon) = NavigationDirectionHelper.directionTextAndIcon(for: feature.properties.turnType, feature: feature)

            VStack(spacing: 2) {
                Text("다음 지점까지 거리")
                    .font(.system(size: 18, weight: .bold))
                Text("\(Int(distance)) m")
                    .font(.system(size: 30, weight: .bold))

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
            .padding(.bottom, 4)
            .background(
                Color.clear.onAppear {
                    let spokenText = NavigationDirectionHelper.instructionText(for: feature, distance: distance)
                    if !spokenText.isEmpty {
                        pendingInstructionText = spokenText
                        shouldSpeakInstruction = true
                    }

                    if turnType == 201 {
                        Task {
                            do {
                                let data = try await HealthKitManager.shared.fetchHealthData(with: current)
                                DispatchQueue.main.async {
                                    self.healthData = data
                                    self.showHealthSubmitPrompt = true
                                }
                            } catch {
                                print("❌ 건강 데이터 수집 실패: \(error)")
                            }
                        }
                    }
                }
            )

        } else {
            Text("다음 안내 지점을 찾을 수 없습니다.")
        }
    }

    private func handleLocationUpdate(_ current: CLLocationCoordinate2D) {
        print("📍 현재 위치: \(current.latitude), \(current.longitude)")

        if let previous = previousLocation {
            let distance = calculateDistance(from: previous, to: current)

            if distance < 3 {
                stationaryCounter += 1
                print("⚠️ 동일 위치 감지 횟수 증가: \(stationaryCounter)")
            } else {
                stationaryCounter = 0
            }

            if stationaryCounter >= 10 && !showStayPrompt {
                showStayPrompt = true
                speechManager.speak("현재 같은 곳에 머물러 계신 것으로 확인됩니다. 괜찮으신가요?")
            }
        }

        previousLocation = current
    }

    private func triggerSpeech(for message: String) {
        speechManager.speak(message)
        var vibrationCount = 1
        switch message {
        case "직진하세요": vibrationCount = 1
        case "좌회전하세요": vibrationCount = 2
        case "우회전하세요": vibrationCount = 3
        case "유턴하세요": vibrationCount = 4
        default: vibrationCount = 1
        }

        for i in 0..<vibrationCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.3) {
                WKInterfaceDevice.current().play(.notification)
            }
        }

        shouldSpeakInstruction = false
    }

    private func startEmergencyCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if emergencyCountdown <= 1 {
                timer.invalidate()
                showEmergencyPrompt = false

                HealthKitManager.shared.sendEmergencyRequest(
                    userId: Int64(userId),
                    event: "움직임 없음"
                )

                print("🚨 구조 요청 발송됨")
            } else {
                emergencyCountdown -= 1
            }
        }
    }

    private func nearestInstructionFeature(from location: CLLocationCoordinate2D) -> (Int, RouteFeature)? {
        return result.features
            .enumerated()
            .filter { $0.element.properties.turnType != nil }
            .min(by: { lhs, rhs in
                guard let lhsCoord = lhs.element.geometry.coordinates?.first,
                      let rhsCoord = rhs.element.geometry.coordinates?.first else {
                    return false
                }

                let fromLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                let lhsLocation = CLLocation(latitude: lhsCoord[1], longitude: lhsCoord[0])
                let rhsLocation = CLLocation(latitude: rhsCoord[1], longitude: rhsCoord[0])

                return fromLocation.distance(from: lhsLocation) < fromLocation.distance(from: rhsLocation)
            })
    }

    private func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let fromLoc = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLoc = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLoc.distance(from: toLoc)
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
