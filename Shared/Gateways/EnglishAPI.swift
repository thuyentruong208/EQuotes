//
//  EnglishAPI.swift
//  EQuotes
//
//  Created by Thuyên Trương on 18/09/2022.
//

import Foundation
import Combine

protocol EnglishAPI {
    func translate(_ text: String) -> AnyPublisher<String, Error>
}

class RealEnglishAPI {
    let client: APIClient

    init(client: APIClient = RealAPIClient(baseURLString: APIClientProvider.translateEndpoint)) {
        self.client = client
    }
}

extension RealEnglishAPI: EnglishAPI {
    func translate(_ text: String) -> AnyPublisher<String, Error> {
        return Just<URLRequest>(
            self.client.buildRequest(
                method: "POST",
                path: "",
                queryItems: [
                    "key": APIClientProvider.translateAPIKey
                ],
                body: [
                    "q": text,
                    "source": "en",
                    "target": "vi",
                    "format": "text"
                ]
            )
        )
        .setFailureType(to: Error.self)
        .flatMap { [unowned self] in
            self.client.executeRequest($0, expectType: TranslateResponse.self)
        }
        .map { $0.translatedText.first ?? "" }
        .eraseToAnyPublisher()
    }
}
