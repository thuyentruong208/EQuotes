//
//  LearnView.swift
//  EQuotes
//
//  Created by Thuyên Trương on 30/08/2022.
//

import SwiftUI

struct LearnView: View {
    @Environment(\.injected) private var injected: DIContainer
    @EnvironmentObject var quoteState: QuoteState


    var body: some View {

        VStack {
            if let toDate = quoteState.toDateLoadable.value {
                Text(toDate?.formatted() ?? "")
                    .textFormatting(.primaryText)
            }

            Text("Swipe right to done")

            Button {
                injected.interactors.quotesInteractor.generateLearnQuotes(force: true)
            } label: {
                Text("More")
            }


            let quoteItems = quoteState.learnQuotesLoadable.value ?? []
            if quoteItems.isEmpty {
                Text("Hurray!!!")
            } else {
                QuoteListView(quoteItems: quoteItems, isLearnMode: true)
            }

        }
        .onAppear {
            print("Come here")
            injected.interactors.quotesInteractor.loadSettings()
            injected.interactors.quotesInteractor
                .loadLearnQuotes()
        }
        .onChange(of: quoteState.toDateLoadable) { _ in
            injected.interactors.quotesInteractor.generateLearnQuotes(force: false)
        }

    }
}

struct LearnView_Previews: PreviewProvider {
    static var previews: some View {
        LearnView()
    }
}
