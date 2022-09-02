//
//  AppState.swift
//  EQuotes
//
//  Created by Thuyên Trương on 30/08/2022.
//

import Foundation
import Firebase

class AppState: ObservableObject {
    var quoteState = QuoteState()
}

class QuoteState: ObservableObject {
    @Published var quotesLoadable: Loadable<[QuoteItem]> = .notRequested
    var quotesListener: ListenerRegistration?
    @Published var toDateLoadable: Loadable<Date?> = .notRequested
    @Published var learnQuotesLoadable: Loadable<[QuoteItem]> = .notRequested
    var learnQuotesListener: ListenerRegistration?
    var toDateDataListener: ListenerRegistration?
}


