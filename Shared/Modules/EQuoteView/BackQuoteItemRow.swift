//
//  BackQuoteItemRow.swift
//  EQuotes
//
//  Created by Thuyên Trương on 31/08/2022.
//

import SwiftUI

struct BackQuoteItemRow: View {

    var quoteItem: QuoteItem
    @Binding var show: Bool
    @State var degree: Double = -90

    var body: some View {
        ZStack {
            VStack {
                if let askContent = quoteItem.ask, !askContent.isEmpty {
                    Text(askContent)
                        .textFormatting(.secondaryText)
                        .multilineTextAlignment(.center)
                }

                let images = quoteItem.images?.split(separator: ",").map(String.init) ?? []

                HStack {
                    ForEach(images, id: \.self) { (image) in
                        AsyncImage(url: URL(string: image)) { (phrase) in
                            switch phrase {
                            case .empty:
                                ProgressView()

                            case .success(let image):
                                image.resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: 250, maxHeight: 250)
                            default:
                                Rectangle()
                                    .frame(width: 100, height: 100)
                                    .background(Color.gray)
                            }

                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .disabled(true)
            .padding()
            .background(Color.white.opacity(0.65))
            .cornerRadius(20)
        }
        .onChange(of: show, perform: { newValue in
            withAnimation(.linear(duration: 0.2)) {
                degree = show ? -90 : 0
            }

        })
        .rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))
        .frame(maxWidth: show ? .infinity : 0, maxHeight: show ? .infinity : 0)
        .onAppear {
            degree = show ? 0 : -90
        }
    }
}

struct BackQuoteItemRow_Previews: PreviewProvider {
    static var previews: some View {
        BackQuoteItemRow(quoteItem: QuoteItem(
            en: "* This is **bold** text, this is *italic* text, and this is ***bold, italic*** text.",
            vi: "Sme thing to saySme thing to saySme thing to saySme thing to saySme thing to saySme thing to saySme thing to saySme thing to saySme thing to saySme thing to say",
            ask: ""
        ),
                         show: .constant(true))
    }
}
