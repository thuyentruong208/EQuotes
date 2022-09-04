//
//  Firebase+ModelName.swift
//  EQuotes
//
//  Created by Thuyên Trương on 04/09/2022.
//

import Foundation

struct DB {
    static let quoteItems = "quoteItems"
    static let userSettings = "userSettings"
    static let learnQuotes = "learnQuotes"

    struct KeyID {
        static let toDate = "toDate"
    }

    struct Fields {
        static let createdAt = "createdAt"
        static let value = "value"
        static let quoteID = "quoteID"
    }
}


