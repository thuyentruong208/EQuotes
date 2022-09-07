//
//  EQuotesInteractor.swift
//  EQuotes
//
//  Created by Thuyên Trương on 30/08/2022.
//

import Combine
import Firebase
import FirebaseFirestore
import SwiftUI

protocol QuotesInteractor {

    func listenItems()
    func generateLearnQuotes(force: Bool)
    func loadSettings()
    func addQuote(item: QuoteItem, result: @escaping InteractorResult<Void>)
    func updateQuote(item: QuoteItem, result: @escaping InteractorResult<Void>)
    func loadLearnQuotes()
    func doneLearnQuote(item: QuoteItem)

}

class RealEQuotesInteractor: ObservableObject, QuotesInteractor {

    fileprivate let dbManager: DatabaseManager
    fileprivate let appState: AppState
    fileprivate var cancelBag = Set<AnyCancellable>()

    init(dbManager: DatabaseManager,
         appState: AppState) {
        self.dbManager = dbManager
        self.appState = appState
    }

    func listenItems() {
        dbManager.observeList(
            QuoteItem.self,
            in: DB.quoteItems,
            order: (by: DB.Fields.createdAt, descending: true)
        )
        .sink(receiveCompletion: { (completion) in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                logger.error("Error: \(error)")
            }

        }, receiveValue: { [weak appState] items in
            guard let appState = appState else {
                return
            }
            appState.quoteState.quotesLoadable = .loaded(items)
        })
        .store(in: &cancelBag)
    }

    func loadSettings() {
        dbManager.observeItem(
            [String: Date].self,
            in: DB.userSettings,
            key: DB.KeyID.toDate
        )
        .sink(receiveCompletion: { [weak appState] (completion) in
            guard let appState = appState else {
                return
            }

            switch completion {
            case .finished:
                break
            case .failure(let error):
                if let error = error as? DecodingError {
                    if case .valueNotFound = error {
                        appState.quoteState.toDateLoadable = .loaded(nil)
                        return
                    }
                }

                appState.quoteState.toDateLoadable.setFailed(error: error)
            }

        }, receiveValue: { [weak appState] (data) in
            guard let appState = appState else {
                return
            }

            let value = data[DB.Fields.value]
            appState.quoteState.toDateLoadable = .loaded(value)

        })
        .store(in: &cancelBag)
    }

    func generateLearnQuotes(force: Bool = false) {
        if case let .loaded(toDate) = appState.quoteState.toDateLoadable {

            var numberOfNewQuotes = 0
            if let toDate = toDate {
                var diff = Calendar.current.numberOfDaysBetween(toDate, and: Date())
                diff = diff <= 0 ? 0 : diff
                numberOfNewQuotes = diff * 5
            } else {
                numberOfNewQuotes = 5
            }

            var newQuotes: [QuoteItem] = []
            var setQuotes = Set((appState.quoteState.learnQuotesLoadable.value ?? []).map { $0.rID } )

            var newToDate = Date()

            if force && numberOfNewQuotes == 0 {
                newToDate = toDate?.addingTimeInterval(24 * 3600) ?? Date()
                numberOfNewQuotes = 5
            }

            guard numberOfNewQuotes > 0 else {
                return
            }

            while numberOfNewQuotes > 0 {
                guard let newQuote = (appState.quoteState.quotesLoadable.value ?? []).randomElement() else {
                    break
                }
                if !setQuotes.contains(newQuote.rID) {
                    newQuotes.append(newQuote)
                    setQuotes.insert(newQuote.rID)
                    numberOfNewQuotes -= 1
                }
            }

            let storedNewQuotes = newQuotes.map {
                [
                    DB.Fields.quoteID: $0.rID,
                    DB.Fields.createdAt: Date()
                ]
            }


            dbManager.create([
                (
                    items: storedNewQuotes,
                    collectionPath: DB.learnQuotes,
                    documentKey: nil
                ),
                (
                    items: [[DB.Fields.value: newToDate]],
                    collectionPath: DB.userSettings,
                    documentKey: DB.KeyID.toDate
                )
            ])
            .sink(receiveCompletion: { [weak appState] (completion) in
                guard let appState = appState else {
                    return
                }

                switch (completion) {
                case .finished:
                    appState.quoteState.toDateLoadable = .loaded(newToDate)
                case let .failure(error):
                    logger.error("Error: \(error)")
                }

            }, receiveValue: { _ in })
            .store(in: &cancelBag)
        }
    }

    func loadLearnQuotes() {
        dbManager.observeList(
            LearnQuote.self,
            in: DB.learnQuotes,
            order: (by: DB.Fields.createdAt, descending: true)
        )
        .map { (items) in
            items.compactMap { $0.quoteID }
        }
        .flatMap { [dbManager] (itemIDs) -> AnyPublisher<[QuoteItem], Error> in
            if itemIDs.isEmpty {
                return Just([])
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            } else {
                return dbManager.observeList(QuoteItem.self, keys: itemIDs, in: DB.quoteItems)
            }

        }
        .sink(receiveCompletion: { (completion) in
            switch (completion) {
            case .failure(let error):
                logger.error("Error: \(error)")
            case .finished:
                break
            }

        }, receiveValue: { [unowned appState] (items) in
            appState.quoteState.learnQuotesLoadable = .loaded(items)
        })
        .store(in: &cancelBag)
    }

    func doneLearnQuote(item: QuoteItem) {
        dbManager.delete(DB.Fields.quoteID, isEqualTo: item.rID, in: DB.learnQuotes)
            .sink(receiveCompletion: { (completion) in
                switch (completion) {
                case .failure(let error):
                    logger.error("Error: \(error)")
                case .finished:
                    logger.info("[Done] doneLearnQuote \(item.rID)")
                }

            }, receiveValue: { _ in })
            .store(in: &cancelBag)

    }

    func addQuote(item: QuoteItem, result: @escaping InteractorResult<Void>) {
        dbManager.create(item, in: DB.quoteItems)
            .sinkToResult(result)
            .store(in: &cancelBag)
    }

    func updateQuote(item: QuoteItem, result: @escaping (Result<Void, Error>) -> Void) {
        guard let id = item.id else { return }

        dbManager.update(key: id, item, in: DB.quoteItems)
            .sinkToResult(result)
            .store(in: &cancelBag)
    }
}

struct StubEQuotesInteractor: QuotesInteractor {
    func listenItems() {}
    func generateLearnQuotes(force: Bool) {}
    func loadSettings() {}
    func addQuote(item: QuoteItem, result: InteractorResult<Void>) {}
    func updateQuote(item: QuoteItem, result: (Result<Void, Error>) -> Void) { }
    func loadLearnQuotes() {}
    func doneLearnQuote(item: QuoteItem) {}

}
