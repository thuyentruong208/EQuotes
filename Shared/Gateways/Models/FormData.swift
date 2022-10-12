//
//  FormData.swift
//  EQuotes
//
//  Created by Thuyen Truong on 09/08/2021.
//

import Foundation

struct FormData {

    public init(data: Data, name: String, fileName: String? = nil, contentType: String = "application/octet-stream") {
        self.data = data
        self.name = name
        self.fileName = fileName
        self.contentType = contentType
    }

    let data: Data
    let name: String
    let fileName: String?
    let contentType: String
}
