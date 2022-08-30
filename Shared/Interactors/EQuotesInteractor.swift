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

protocol EQuotesInteractor {

    func listenItems()
    func generateLearnQuotes()
    func loadSettings()
//    func addQuote(item: QuoteItem, result: InteractorResult<Void>)
//    func updateQuote(item: QuoteItem, result: InteractorResult<Void>)

}

class RealEQuotesInteractor: ObservableObject, EQuotesInteractor {

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

        docRef.addSnapshotListener { (snapshot, error) in
            guard let snapshot = snapshot else { return }

            let document = snapshot

//            if document.exists {
                print(document)
                if let item = try? document.data(as: SettingValue.self) {
                    print(Date(timeIntervalSince1970: TimeInterval( item.value)!))
                }
//
////                print("Document data: \(dataDescription)")
//            } else {
//                print("Document does not exist")
//            }
        }

    }

    func generateLearnQuotes() {
        db.collection("userSettings")
            .document("toDate").setData([
            "value": String(Date().timeIntervalSince1970)

        ], merge: true) { error in
            if let error = error {
                print(error)
            }
        }


//        let settings = UserSettings(id: "toDate", value: String(Date().timeIntervalSince1970))
//
//        do {
//            _ = try db.collection("userSettings").addDocument(from: settings)
////            result(.success(()))
//        } catch {
////            result(.failure(error))
//        }
    }

//    func addQuote(item: QuoteItem, result: InteractorResult<Void>) {
//        do {
//            _ = try db.collection("quoteItems").addDocument(from: item)
//            result(.success(()))
//        } catch {
//            result(.failure(error))
//        }
//    }
//
//    func updateQuote(item: QuoteItem, result: (Result<Void, Error>) -> Void) {
//        guard let id = item.id else { return }
//
//        do {
//            try db.collection("quoteItems").document(id).setData(from: item)
//            result(.success(()))
//        } catch {
//            result(.failure(error))
//        }
//    }
}

struct StubEQuotesInteractor: EQuotesInteractor {
    func listenItems() {}
    func generateLearnQuotes() {}
    func loadSettings() {}
//    func updateQuote(item: QuoteItem, result: (Result<Void, Error>) -> Void) {
//
//    }
//
//    func listenItems(loadable: Binding<Loadable<[QuoteItem]>>, result: InteractorResult<ListenerRegistration>) {
//
//    }
//    func addQuote(item: QuoteItem, result: InteractorResult<Void>) {}

}
