//
//  QuoteItemRow.swift
//  EQuotes
//
//  Created by Thuyên Trương on 30/08/2022.
//

import SwiftUI

struct QuoteItemRow: View {

    var quoteItem: QuoteItem
    @Binding var show: Bool
    @State var degree: Double = 0

    init(_ quoteItem: QuoteItem, show: Binding<Bool>) {
        self.quoteItem = quoteItem
        self._show = show
    }

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
                    .textFormatting(.secondaryText)
                    .padding(.vertical, 5)
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(alignment: .topLeading)
        .padding()
        .background(Color.white.opacity(0.65))
        .cornerRadius(20)
        .onChange(of: show, perform: { newValue in
            withAnimation(.linear(duration: 0.2)) {
                degree = show ? 90 : 0
            }

        })
        .rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))
        .frame(maxWidth: show ? .infinity : 0, maxHeight: show ? .infinity : 0)
        .onAppear {
            degree = show ? 0 : 90
        }
    }
}

struct QuoteItemRow_Previews: PreviewProvider {
    static var previews: some View {
        QuoteItemRow(QuoteItem(
            en: "* This is **bold** text, this is *italic* text, and this is ***bold, italic*** text.",
            vi: "Sme thing to saySme thing to saySme thing to saySme thing to saySme thing to saySme thing to saySme thing to saySme thing to saySme thing to saySme thing to say",
            ask: ""
        ),
                     show: .constant(true)
        )
    }
}

