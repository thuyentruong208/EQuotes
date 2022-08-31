//
//  BackQuoteItemRow.swift
//  EQuotes
//
//  Created by Thuyên Trương on 31/08/2022.
//

import SwiftUI
import MarkdownUI

struct BackQuoteItemRow: View {

    var content: String
    @Binding var show: Bool
    @State var degree: Double = -90

    var body: some View {
        ZStack {
            VStack {
                Markdown(content)
                    .disabled(true)
            }
            .padding()
            .background(Color.white.opacity(0.65))
            .cornerRadius(20)
        }
        .onChange(of: show, perform: { newValue in
            withAnimation {
                degree = show ? -90 : 0
            }

        })
        .rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))
    }
}

struct BackQuoteItemRow_Previews: PreviewProvider {
    static var previews: some View {
        BackQuoteItemRow(content: "* This is **bold** text, this is *italic* text, and this is ***bold, italic*** text.",
                         show: .constant(true))
    }
}
