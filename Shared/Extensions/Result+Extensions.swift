//
//  Result+Extensions.swift
//  EQuotes
//
//  Created by Thuyên Trương on 31/08/2022.
//

import Foundation

extension Result {
    func isSuccess(ifFailure completion: @escaping (Error) -> ()) -> Bool {
        switch self {
        case .success:
            return true

        case let .failure(error):
            completion(error)
            return false
        }
    }

    func get(ifFailure completion: @escaping (Error) -> ()) -> Success? {
        switch self {
        case let .success(value):
            return value

        case let .failure(error):
            completion(error)
            return nil
        }

    }
}
