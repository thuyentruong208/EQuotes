//
//  QuoteListView.swift
//  EQuotes
//
//  Created by Thuyên Trương on 02/09/2022.
//

import SwiftUI

struct QuoteListView: View {

    let quoteItems: [QuoteItem]
    let isLearnMode: Bool
    @State var editQuoteView: QuoteItem?
    @State var showBackFaceQuoteItems = Set<String>()
    @Environment(\.injected) private var injected: DIContainer

    init(quoteItems: [QuoteItem], isLearnMode: Bool) {
        self.quoteItems = quoteItems
        self.isLearnMode = isLearnMode

        if isLearnMode {
            _showBackFaceQuoteItems = State(initialValue: Set(quoteItems.map(\.rID))) 
        }
    }

    var body: some View {
        VStack {
            if isLearnMode {
                Text("Swipe right to done")
                    .textFormatting(.secondaryTextWith(Color.white.opacity(0.6)))
                    .foregroundColor(Color.white)
            }

            LazyVStack(alignment: .center, spacing: 20) {
                ForEach(quoteItems) { (quoteItem) in
                    itemRow(for: quoteItem)
                        .gesture(DragGesture(minimumDistance: 10, coordinateSpace: .local)
                            .onEnded({ value in
                                if isLearnMode && value.translation.width > 0 {
                                    injected.interactors.quotesInteractor
                                        .doneLearnQuote(item: quoteItem)
                                }
                            }))
                }
            }
            .sheet(item: $editQuoteView, content: { quoteItem in
                AddNewQuoteView(quoteItem: quoteItem)
            })
            .padding(.horizontal, 15)
        }
    }

    func itemRow(for quoteItem: QuoteItem) -> some View {
#if os(macOS)
        return HStack {

            quoteItemView(quoteItem: quoteItem)

            VStack(alignment: .center) {
                Image(systemName: "pencil.tip.crop.circle.badge.arrow.forward")
                    .resizable()
                    .frame(width: 22, height: 20)
                    .foregroundColor(colorTheme.accent)
                    .onTapGesture {
                        editQuoteView = quoteItem
                    }
                    .padding(.bottom, 13)

                Image(systemName: "speaker.wave.2.fill")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .foregroundColor(colorTheme.accent)
                    .onTapGesture {
                        injected.interactors.helpersInteractor.speak(text: quoteItem.en)
                    }
            }
            .padding(8)
        }
#else
        return quoteItemView(quoteItem: quoteItem)
            .overlay(
                Image(systemName: "speaker.wave.2.fill")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .foregroundColor(Color.black)
                    .offset(x: -13, y: -20)
                    .onTapGesture {
                        injected.interactors.helpersInteractor.speak(text: quoteItem.en)
                    }
                , alignment: .bottomTrailing
            )
#endif
    }

    func quoteItemView(quoteItem: QuoteItem) -> some View {
        let front = !showBackFaceQuoteItems.contains(quoteItem.rID)

        return ZStack {
            QuoteItemRow(quoteItem, show: .constant(front))
                .frame(maxWidth: 500)

            BackQuoteItemRow(quoteItem: quoteItem, show: .constant(!front))
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
