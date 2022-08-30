//
//  LearnView.swift
//  EQuotes
//
//  Created by Thuyên Trương on 30/08/2022.
//

import SwiftUI

struct LearnView: View {
    @Environment(\.injected) private var injected: DIContainer


    var body: some View {



        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)

        Button {
//            injected.interactors.quotesInteractor.generateLearnQuotes()
            injected.interactors.quotesInteractor.loadSettings()

//                        submitNewQuote()

        } label: {
            Text("SUBMIT")
        }
        .buttonStyle(GrowingButton())

    }
}

struct LearnView_Previews: PreviewProvider {
    static var previews: some View {
        LearnView()
    }
}
