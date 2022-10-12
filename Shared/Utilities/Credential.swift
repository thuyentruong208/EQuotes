//
//  Credential.swift
//  EQuotes
//
//  Created by Thuyên Trương on 20/09/2022.
//

import Foundation

class Credential {
    public static func valueForKey<T>(keyName: String) -> T {
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: "Credentials", ofType: "plist")!)
        let data = try! Data(contentsOf: url)

        guard let plist = try! PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [String: Any] else {
            fatalError()
        }

        return plist[keyName] as! T
    }
}
