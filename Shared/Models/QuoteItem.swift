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
    var images: String?
    @ServerTimestamp var createdAt: Timestamp?

    var rID: String {
        id ?? ""
    }
}

extension QuoteItem: Equatable {

}

extension QuoteItem {

    func copyWith(en: String? = nil, vi: String? = nil, ask: String? = nil, images: String? = nil) -> QuoteItem {
        return QuoteItem(
            id: self.id,
            en: en ?? self.en,
            vi: vi ?? self.vi,
            ask: ask ?? self.ask,
            images: images ?? self.images,
            createdAt: createdAt
        )
    }
}
