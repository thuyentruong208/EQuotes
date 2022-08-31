//
//  QuoteItemRow.swift
//  EQuotes
//
//  Created by Thuyên Trương on 30/08/2022.
//

import SwiftUI
import MarkdownUI

struct QuoteItemRow: View {
    var quoteItem: QuoteItem

    var body: some View {
        VStack {
            Text(quoteItem.en.markdownToAttributed())
                .textFormatting(.primaryText)
                .padding(.vertical, 5)
                .multilineTextAlignment(.center)

            if let viText = quoteItem.vi, !viText.isEmpty {
                Divider()
                    .background(Color.black)

                Text(viText.markdownToAttributed())
                    .textFormatting(.seconddaryText)
                    .padding(.vertical, 5)
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(Color.white.opacity(0.65))
        .cornerRadius(20)
    }
}

struct QuoteItemRow_Previews: PreviewProvider {
    static var previews: some View {
        QuoteItemRow(quoteItem: QuoteItem(
            en: "* This is **bold** text, this is *italic* text, and this is ***bold, italic*** text.",
            vi: "Sme thing to saySme thing to saySme thing to saySme thing to saySme thing to saySme thing to saySme thing to saySme thing to saySme thing to saySme thing to say",
            ask: ""
            )
        )
    }
}

