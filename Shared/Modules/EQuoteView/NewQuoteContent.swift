//
//  NewQuoteContent.swift
//  EQuotes
//
//  Created by Thuyên Trương on 30/08/2022.
//

import Foundation

class NewQuoteContent: ObservableObject {

    var id: String?
    @Published var content: String = ""

    init(id: String? = nil, en: String? = nil, vi: String? = nil) {
        self.id = id
        self.content = en == nil ? "" : "\(en)\n\n\(vi)"
    }

    convenience init(quoteItem: QuoteItem?) {
        self.init()
        self.id = quoteItem?.id
        self.content = quoteItem == nil ? "" : "\(quoteItem?.en ?? "")\n\n\n\(quoteItem?.vi ?? "")"
    }

    func toQuoteItem() -> QuoteItem {
        let components = content.components(separatedBy: "\n\n")
        let en = components.first ?? ""

        var vi = components.count == 1 ? nil : components.last

        if vi?.isEmpty ?? true {
            vi = nil
        }

        return QuoteItem(
            id: id,
            en: en,
            vi: vi
        )
    }

    func clear() {
        id = nil
        content = ""
    }
}
