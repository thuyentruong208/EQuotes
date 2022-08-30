//
//  QuoteItemRow.swift
//  EQuotes
//
//  Created by Thuyên Trương on 30/08/2022.
//

import SwiftUI

struct QuoteItemRow: View {
    var quoteItem: QuoteItem

    var body: some View {
        VStack {
            Text(quoteItem.en.markdownToAttributed())
                #if os(iOS)
                .font(.custom("Avenir Next Condensed", size: 18))
                #endif
                #if os(macOS)
                .font(.custom("Avenir Next Condensed", size: 22))
                #endif
                .padding(.vertical, 5)
                .foregroundColor(Color.black)
                .multilineTextAlignment(.center)

            if let viText = quoteItem.vi, !viText.isEmpty {
                Divider()
                    .background(Color.black)

                Text(viText.markdownToAttributed())
                    .font(.callout)
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
            tags: ["🎽 DailyLife", "🥰 Love"])
        )
    }
}

