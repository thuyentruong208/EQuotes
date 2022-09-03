//
//  HelpersInteractor.swift
//  EQuotes
//
//  Created by Thuyên Trương on 03/09/2022.
//

import Foundation
import AVFoundation

protocol HelpersInteractor {
    func speak(text: String)
}

class RealHelpersInteractor: HelpersInteractor {
    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5

        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
}

class StubHelpersInteractor: HelpersInteractor {
    func speak(text: String) {}
}
