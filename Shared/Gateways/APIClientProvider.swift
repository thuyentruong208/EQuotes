//
//  APIClientProvider.swift
//  EQuotes
//
//  Created by Thuyên Trương on 18/09/2022.
//

import Foundation

class APIClientProvider {
    static let translateAPIKey: String = Credential.valueForKey(keyName: "TRANSLATE_API_KEY")
    static let translateEndpoint = "https://translation.googleapis.com/language/translate/v2"

    static let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.httpShouldSetCookies = false
        return URLSession(configuration: configuration)
    }()

    static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.init(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'H:mm:ss.SSS'Z"
        return dateFormatter
    }()
}
