//
//  Responses.swift
//  EQuotes
//
//  Created by Thuyen Truong on 09/08/2021.
//

import Foundation

struct APIErrorResponse: Codable {
    let error: APIErrorObject
}

// MARK: - Error
struct APIErrorObject: Codable {
    let code: Int
    let message: String
}

struct TranslateResponse: Decodable {

    var translatedText: [String]

    enum CodingKeys: String, CodingKey {
        case data
        case translations
    }

    enum TranslationsKey: String, CodingKey {
        case translatedText
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        var translatedTextContainer = try values
                .nestedContainer(keyedBy: CodingKeys.self, forKey: .data)
                .nestedUnkeyedContainer(forKey: .translations)

        self.translatedText = []

        while !translatedTextContainer.isAtEnd {
            self.translatedText.append(
                try translatedTextContainer.nestedContainer(keyedBy: TranslationsKey.self)
                .decode(String.self, forKey: .translatedText)
            )
        }
    }
}
