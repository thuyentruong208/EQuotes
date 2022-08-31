//
//  Quote.swift
//  EQuotes
//
//  Created by Thuyên Trương on 30/08/2022.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct QuoteItem: Codable, Identifiable {
    @DocumentID var id: String?
    var en: String
    var vi: String?
    var ask: String?
    @ServerTimestamp var createdAt: Timestamp?

    var rID: String {
        id ?? ""
    }
}

extension QuoteItem: Equatable {

}
