//
//  String+Extensions.swift
//  EQuotes
//
//  Created by Thuyên Trương on 30/08/2022.
//

import Foundation

extension String {
    func markdownToAttributed() -> AttributedString {
        do {
            return try AttributedString(markdown: self) /// convert to AttributedString
        } catch {
            return AttributedString("Error parsing markdown: \(error)")
        }
    }
}
