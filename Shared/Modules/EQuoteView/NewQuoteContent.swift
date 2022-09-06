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
    @Published var askContent: String = ""
    @Published var askImages: String = ""

    convenience init(quoteItem: QuoteItem?) {
        self.init()
        self.id = quoteItem?.id
        self.content = quoteItem == nil ? "" : "\(quoteItem?.en ?? "")||\(quoteItem?.vi ?? "")"
        self.askContent = quoteItem?.ask ?? ""
        self.askImages = quoteItem?.images ?? ""
    }

    func toQuoteItem() -> QuoteItem {
        let components = content.components(separatedBy: "||")
        let en = components.first ?? ""

        var vi = components.count == 1 ? nil : components.last

        if vi?.isEmpty ?? true {
            vi = nil
        }

        return QuoteItem(
            id: id,
            en: en,
            vi: vi,
            ask: askContent,
            images: askImages
        )
    }

    func clear() {
        id = nil
        content = ""
        askContent = ""
        askImages = ""
    }
}
