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

    let synthesizer = AVSpeechSynthesizer()

    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.35

        synthesizer.speak(utterance)
    }
}

class StubHelpersInteractor: HelpersInteractor {
    func speak(text: String) {}
}
