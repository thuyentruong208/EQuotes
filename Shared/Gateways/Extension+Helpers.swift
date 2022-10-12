//
//  Extension+Helpers.swift
//  EQuotes
//
//  Created by Thuyên Trương on 11/10/2022.
//

import Foundation

extension String {
    func formatDate(_ dateFormat: String = "EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.init(abbreviation: "GMT")
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.date(from: self)
    }
}
