//
//  Interacters.swift
//  EQuotes
//
//  Created by Thuyên Trương on 30/08/2022.
//

import Foundation

typealias InteractorResult<T> = (Result<T, Error>) -> Void

struct Interactors {
    let quotesInteractor: QuotesInteractor
    let helpersInteractor: HelpersInteractor
    let eventsInteractor: EventsInteractor

    init(quotesInteractor:QuotesInteractor,
         helpersInteractor: HelpersInteractor,
         eventsInteractor: EventsInteractor) {
        self.quotesInteractor = quotesInteractor
        self.helpersInteractor = helpersInteractor
        self.eventsInteractor = eventsInteractor
    }

    static var stub: Self {
        .init(
            quotesInteractor: StubEQuotesInteractor(),
            helpersInteractor: StubHelpersInteractor(),
            eventsInteractor: StubEventsInteractor()
        )
    }
}
