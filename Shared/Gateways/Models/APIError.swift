//
//  APIError.swift
//  EQuotes
//
//  Created by Thuyen Truong on 09/08/2021.
//

import Foundation

public enum APIError: Error, Equatable {
    case notFound
    case invalidRequest
    case apiError(code: Int, reason: String)
    case noIntenetConnection
    case invalidResponseFormat
    case other(reason: String)

    func `is`(_ apiError: APIErrorCode) -> Bool {
        switch self {
        case .apiError(let code, _):
            return code == apiError.rawValue
        default:
            return false
        }
    }
}

extension APIError: LocalizedError {
    public var errorDescription: String {
        errorMessage
    }

    public var failureReason: String? {
        errorMessage
    }

    public var recoverySuggestion: String? {
        errorMessage
    }

    var errorMessage: String {
        switch self {
        case .notFound:
            return "notFound"
        case .invalidRequest:
            return "invalidRequest"
        case .apiError(let code, let reason):
            return "\(code) - \(reason)"
        case .noIntenetConnection:
            return "noIntenetConnection"
        case .invalidResponseFormat:
            return "invalidResponseFormat"
        case .other(let reason):
            return reason
        }
    }
}

enum APIErrorCode: Int {
    case invalidToken = 7001
}
