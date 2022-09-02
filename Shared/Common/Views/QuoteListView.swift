//
//  QuoteListView.swift
//  EQuotes
//
//  Created by Thuyên Trương on 02/09/2022.
//

import SwiftUI

struct QuoteListView: View {

    let quoteItems: [QuoteItem]
    @State var editQuoteView: QuoteItem?
    @State var showBackFaceQuoteItems = Set<String>()

    var body: some View {
        LazyVStack(alignment: .center, spacing: 20) {
            ForEach(quoteItems) { (quoteItem) in
                itemRow(for: quoteItem)
            }
        }
        .sheet(item: $editQuoteView, content: { quoteItem in
            AddNewQuoteView(quoteItem: quoteItem)
        })
        .padding()

    }

    func itemRow(for quoteItem: QuoteItem) -> some View {
        #if os(macOS)
            return HStack {

                Image(systemName: "pencil.circle.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundColor(colorTheme.accent)
                    .offset(x: -10, y: -10)
                    .onTapGesture {
                        editQuoteView = quoteItem
                    }

                quoteItemView(quoteItem: quoteItem)
            }
        #else
        return quoteItemView(quoteItem: quoteItem)
        #endif
    }

    func quoteItemView(quoteItem: QuoteItem) -> some View {
        let front = !showBackFaceQuoteItems.contains(quoteItem.id ?? "")

        return ZStack {
                QuoteItemRow(quoteItem, show: .constant(front))
                        .frame(maxWidth: 500)

                BackQuoteItemRow(content: quoteItem.ask ?? "", show: .constant(!front))
                    .frame(maxWidth: 500)
        }
        .onTapGesture {
            flipCard(quoteItem, !front)
        }
    }

    func flipCard(_ quoteItem: QuoteItem, _ front: Bool) {
        if front {
            showBackFaceQuoteItems.remove(quoteItem.rID)
        } else {
            showBackFaceQuoteItems.insert(quoteItem.rID)
        }
    }
}
