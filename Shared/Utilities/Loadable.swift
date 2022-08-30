//
//  Loadable.swift
//  EQuotes
//
//  Created by Thuyên Trương on 30/08/2022.
//

import Foundation
import Combine

enum Loadable<T> {

    case notRequested
    case isLoading(last: T?, cancelBag: CancelBag?)
    case loaded(T)
    case failed(last: T?, error: Error)

    var value: T? {
        switch self {
        case let .loaded(value): return value
        case let .isLoading(last, _): return last
        case let .failed(last, _): return last
        default: return nil
        }
    }

    var error: Error? {
        switch self {
        case let .failed(_, error): return error
        default: return nil
        }
    }
}

extension Loadable {
    mutating func setIsLoading(cancelBag: CancelBag? = nil) {
        self = .isLoading(last: value, cancelBag: cancelBag)
    }

    mutating func endIsLoading() {
        if let value = value {
            self = .loaded(value)
        } else {
            self = .notRequested
        }
    }

    mutating func setFailed(error: Error) {
        self = .failed(last: value, error: error)
    }
}

extension Loadable: Equatable where T: Equatable {
    static func == (lhs: Loadable<T>, rhs: Loadable<T>) -> Bool {
        switch (lhs, rhs) {
        case (.notRequested, .notRequested): return true
        case let (.isLoading(lhsV, _), .isLoading(rhsV, _)): return lhsV == rhsV
        case let (.loaded(lhsV), .loaded(rhsV)): return lhsV == rhsV
        case let (.failed(lhsV, lhsE), .failed(rhsV, rhsE)):
            return lhsV == rhsV && lhsE.localizedDescription == rhsE.localizedDescription
        default: return false
        }
    }
}

