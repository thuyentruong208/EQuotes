//
//  Settings.swift
//  EQuotes
//
//  Created by Thuyên Trương on 30/08/2022.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct UserSettings: Codable, Identifiable {

    var id: String
    var value: String
}

struct SettingValue: Codable {
    var value: String
}

extension UserSettings: Equatable {

}
