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
                    .textFormatting(.primaryTextWith(Color.white))

            }

            switch quoteState.learnQuotesLoadable {
            case .notRequested:
                ProgressView()
            default:
                let quoteItems = quoteState.learnQuotesLoadable.value ?? []
                if quoteItems.isEmpty {
                    VStack {
                        Image("victory")
                            .resizable()

                        Button {
                            injected.interactors.quotesInteractor.generateLearnQuotes(force: true)
                        } label: {
                            Text("More")
                        }
                        .frame(width: 150, height: 30)
                        .buttonStyle(RoundedRectangleButtonStyle())
                    }
                    .padding(50)

                } else {
                    QuoteListView(quoteItems: quoteItems, isLearnMode: true)
                        .padding(.bottom, 40)
                }
            }

        }
        .onAppear {
            injected.interactors.quotesInteractor.loadSettings()
            injected.interactors.quotesInteractor
                .loadLearnQuotes()
            injected.interactors.quotesInteractor.loadLearnData()
        }
        .onChange(of: quoteState.toDateLoadable) { _ in
            injected.interactors.quotesInteractor.generateLearnQuotes(force: false)
        }
        .offset(y: -60)


    }
}

struct LearnView_Previews: PreviewProvider {
    static var previews: some View {
        LearnView()
    }
}
