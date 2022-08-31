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
    var showEdit: Bool
    @Binding var editQuoteView: QuoteItem?
    @Binding var show: Bool
    @State var degree: Double = 0

    init(_ quoteItem: QuoteItem, showEdit: Bool = true, editQuoteView: Binding<QuoteItem?>, show: Binding<Bool>) {
        self.quoteItem = quoteItem
        self.showEdit = showEdit
        self._editQuoteView = editQuoteView
        self._show = show
    }

    var body: some View {
        ZStack {
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
            .frame(alignment: .topLeading)
            .padding()
            .background(Color.white.opacity(0.65))
            .cornerRadius(20)

            if showEdit {
                Image(systemName: "pencil.circle.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .offset(x: -10, y: -10)
                    .onTapGesture {
                        editQuoteView = quoteItem
                    }
            }

        }
        .onChange(of: show, perform: { newValue in
            withAnimation {
                degree = show ? 90 : 0
            }

        })
        .rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))

    }
}

struct QuoteItemRow_Previews: PreviewProvider {
    static var previews: some View {
        QuoteItemRow(QuoteItem(
            en: "* This is **bold** text, this is *italic* text, and this is ***bold, italic*** text.",
            vi: "Sme thing to saySme thing to saySme thing to saySme thing to saySme thing to saySme thing to saySme thing to saySme thing to saySme thing to saySme thing to say",
            ask: ""
        ),
                     editQuoteView: .constant(nil),
                     show: .constant(true)
        )
    }
}

