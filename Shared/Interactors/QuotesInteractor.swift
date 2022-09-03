//
//  EQuotesInteractor.swift
//  EQuotes
//
//  Created by Thuyên Trương on 30/08/2022.
//

import Foundation

import Foundation
import Firebase
import FirebaseFirestore
import SwiftUI

protocol QuotesInteractor {

    func listenItems()
    func generateLearnQuotes()
    func loadSettings()
    func addQuote(item: QuoteItem, result: InteractorResult<Void>)
    func updateQuote(item: QuoteItem, result: InteractorResult<Void>)
    func loadLearnQuotes()
    func doneLearnQuote(item: QuoteItem)

}

class RealEQuotesInteractor: ObservableObject, QuotesInteractor {

    fileprivate let db = Firestore.firestore()
    fileprivate let appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    func listenItems() {
        let quotesListener = db.collection("quoteItems")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [self] (snapshot, _) in
                guard let snapshot = snapshot else { return }

                let items = snapshot.documents.compactMap { (document) -> QuoteItem? in
                    try? document.data(as: QuoteItem.self)
                }

                self.appState.quoteState.quotesLoadable = .loaded(items)
            }

        appState.quoteState.quotesListener = quotesListener
    }

    func loadSettings() {
        let docRef = db.collection("userSettings")
            .document("toDate")

        appState.quoteState.toDateDataListener = docRef.addSnapshotListener { [weak self] (snapshot, error) in
            guard let self = self, let snapshot = snapshot else { return }

            do {
                let data = try snapshot.data(as: [String: Date].self)
                self.appState.quoteState.toDateLoadable =  .loaded(data["value"])

            } catch (let exception) {
                if let exception = exception as? DecodingError {
                    if case .valueNotFound = exception {
                        self.appState.quoteState.toDateLoadable = .loaded(nil)
                        return
                    }
                }

                self.appState.quoteState.toDateLoadable.setFailed(error: exception)
            }
        }
    }

    func generateLearnQuotes() {

        if case let .loaded(toDate) = appState.quoteState.toDateLoadable {

            var numberOfNewQuotes = 0
            if let toDate = toDate {
                let diff = Calendar.current.numberOfDaysBetween(toDate, and: Date())
                numberOfNewQuotes = diff * 5
            } else {
                numberOfNewQuotes = 5
            }

            var newQuotes: [QuoteItem] = []
            var setQuotes = Set((appState.quoteState.learnQuotesLoadable.value ?? []).map { $0.rID } )

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

            let batch = db.batch();
            let learnQuoteRef = db.collection("learnQuotes")
            newQuotes.forEach { quote in
                batch.setData(
                    [
                        "quoteID": quote.rID,
                        "createdAt": Date()
                    ],
                    forDocument: learnQuoteRef.document())
                batch.setData(["value": Date()], forDocument: self.db.collection("userSettings").document("toDate"))
            }

            batch.commit { [unowned self] error in
                if let error = error {
                    print(error)
                } else {
                    self.appState.quoteState.toDateLoadable = .loaded(Date())
                }
            }

        }
    }

    func loadLearnQuotes() {
        let learnQuotesListener = db.collection("learnQuotes")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [self] (snapshot, _) in
                guard let documents = snapshot?.documents else { return }

                let learnQuoteIDs = documents.compactMap { (element) -> String? in
                    guard let quoteID = element["quoteID"] as? String else {
                        return nil
                    }

                    return quoteID
                }

                if learnQuoteIDs.isEmpty {
                    self.appState.quoteState.learnQuotesLoadable = .loaded([])

                } else {

                    db.collection("quoteItems")
                        .whereField(FieldPath.documentID(), in: learnQuoteIDs)
                        .addSnapshotListener { [self] (snapshot, _) in
                            guard let snapshot = snapshot else { return }

                            let items = snapshot.documents.compactMap { (document) -> QuoteItem? in
                                try? document.data(as: QuoteItem.self)
                            }

                            self.appState.quoteState.learnQuotesLoadable = .loaded(items)
                        }
                }

            }

        appState.quoteState.learnQuotesListener = learnQuotesListener
    }

    func doneLearnQuote(item: QuoteItem) {
        db.collection("learnQuotes")
            .whereField("quoteID", isEqualTo: item.rID)
            .getDocuments(completion: { [appState] snapshot, error in
                if let error = error {
                    print(error)
                } else {
                    snapshot?.documents.first?.reference.delete()

                    var newLearnQuotes = appState.quoteState.learnQuotesLoadable.value ?? []
                    newLearnQuotes.removeAll(where: { $0.rID == item.rID })
                    appState.quoteState.learnQuotesLoadable = .loaded(newLearnQuotes)
                }
            })

    }

    func addQuote(item: QuoteItem, result: InteractorResult<Void>) {
        do {
            _ = try db.collection("quoteItems").addDocument(from: item)
            result(.success(()))
        } catch {
            result(.failure(error))
        }
    }

    func updateQuote(item: QuoteItem, result: (Result<Void, Error>) -> Void) {
        guard let id = item.id else { return }

        do {
            try db.collection("quoteItems").document(id).setData(from: item)
            result(.success(()))
        } catch {
            result(.failure(error))
        }
    }
}

struct StubEQuotesInteractor: QuotesInteractor {
    func listenItems() {}
    func generateLearnQuotes() {}
    func loadSettings() {}
    func addQuote(item: QuoteItem, result: InteractorResult<Void>) {}
    func updateQuote(item: QuoteItem, result: (Result<Void, Error>) -> Void) { }
    func loadLearnQuotes() {}
    func doneLearnQuote(item: QuoteItem) {}

}
