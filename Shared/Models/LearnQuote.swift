//
//  LearnQuote.swift
//  EQuotes
//
//  Created by Thuyên Trương on 06/09/2022.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

struct LearnQuote: Codable, Identifiable {
    @DocumentID var id: String?
    var quoteID: String
    var createdAt: Date
}

extension LearnQuote: Equatable {

}
