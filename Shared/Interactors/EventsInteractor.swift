//
//  EventsInteractor.swift
//  EQuotes
//
//  Created by Thuyên Trương on 31/08/2022.
//

import Foundation

protocol EventsInteractor {
    func systemError(error: Error, alertUser: Bool)

}

class RealEventsInteractor: EventsInteractor {
    func systemError(error: Error, alertUser: Bool) {
        logger.error("Error: \(error)")
    }
}

struct StubEventsInteractor: EventsInteractor {
    func systemError(error: Error, alertUser: Bool) {}
}
