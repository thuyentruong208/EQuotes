//
//  UserDefault+Data.swift
//  EQuotes
//
//  Created by Thuyên Trương on 30/08/2022.
//

import Foundation

import Foundation

extension UserDefaults {
    var learnMode: Bool {
        get { bool(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }

    var learnedCount: Int {
        get { integer(forKey: #function) }
        set { set(newValue, forKey: #function) }
    }

    var learnedAt: Date {
        get { Date(timeIntervalSince1970: double(forKey: #function)) }
        set { set(newValue.timeIntervalSince1970, forKey: #function) }
    }
}
