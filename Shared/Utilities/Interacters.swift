//
//  Interacters.swift
//  EQuotes
//
//  Created by Thuyên Trương on 30/08/2022.
//

import Foundation

struct Interactors {
    let quotesInteractor: EQuotesInteractor

    init(quotesInteractor: EQuotesInteractor) {
        self.quotesInteractor = quotesInteractor
    }

    static var stub: Self {
        .init(quotesInteractor: StubEQuotesInteractor())
    }
}
