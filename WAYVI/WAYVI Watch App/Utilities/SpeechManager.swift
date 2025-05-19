//
//  SpeechManager.swift
//  WAYVI
//
//  Created by 이지희 on 5/18/25.
//

import AVFoundation

class SpeechManager: NSObject, ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()

    func speak(_ message: String) {
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        synthesizer.speak(utterance)
    }
}
