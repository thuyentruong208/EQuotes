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

    var body: some View {
        VStack {
            Markdown(content)
        }
        .padding()
        .background(Color.white.opacity(0.65))
        .cornerRadius(20)

    }
}

struct BackQuoteItemRow_Previews: PreviewProvider {
    static var previews: some View {
        BackQuoteItemRow(content: "* This is **bold** text, this is *italic* text, and this is ***bold, italic*** text.")
    }
}
