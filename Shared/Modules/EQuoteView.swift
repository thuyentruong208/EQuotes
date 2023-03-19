//
//  EQuoteView.swift
//  EQuotes
//
//  Created by Thuyên Trương on 30/08/2022.
//

import SwiftUI
import Combine

struct EQuoteView: View {
    @Environment(\.injected) private var injected: DIContainer
    @EnvironmentObject var quoteState: QuoteState
    @AppStorage("learnMode") private var learnMode = false
    @State var showAddQuoteView: Bool = false
    var imageSize: CGFloat {
        #if os(macOS)
            return 115
        #else
            return 90
        #endif
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            GradientView(gradientModel: gradients[1])
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                headerView
                    .padding(.bottom, 20)

                if learnMode {
                    LearnView()
                } else {
                    QuoteListView(quoteItems: quoteState.quotesLoadable.value ?? [], isLearnMode: false)
                }

            }


            Text("\(quoteState.learnedCount ?? 0)")
                .font(.system(size: 30))
                .fontWeight(.bold)
                .foregroundColor(Color.green)
                .padding()
                .background(Color.white)
                .clipShape(Capsule())
                .offset(x: -30, y: -30)
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .onAppear {
            injected.interactors.quotesInteractor.listenItems()
        }
        .onDisappear {
            quoteState.quotesListener?.remove()
        }
    }
}

extension EQuoteView {

    var headerView: some View {
        HStack {

            Image("image")
                .resizable()
                .frame(width: imageSize, height: imageSize)
                .padding(EdgeInsets(top: 20, leading: 30, bottom: 0, trailing: 0))

            Spacer()

            HStack {
                VStack(alignment: .trailing) {
                    Toggle("", isOn: $learnMode)
                        .toggleStyle(SwitchToggleStyle())
                        .tint(Color.white)
                        .accentColor(Color.white)
                        .foregroundColor(Color.white)
                        .padding(.bottom, 1)

                    Text("Learn Mode")
                        .textFormatting(.secondaryText)
                }

#if os(macOS)
                addButton
#endif
            }
            .padding()
        }

    }

    var addButton: some View {
        Button(action: {
            showAddQuoteView.toggle()

        }, label: {
            VStack(spacing: 7) {
                Image(systemName: "plus.message.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                Text("Add")
                    .textFormatting(.secondaryText)
            }
        })
        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
        .buttonStyle(.borderless)
        .tint(.pink)
        .foregroundColor(.white)
        .cornerRadius(40)
        .sheet(isPresented: $showAddQuoteView) {
            AddNewQuoteView()
        }
    }
}

struct EQuoteView_Previews: PreviewProvider {
    static var previews: some View {
        EQuoteView()
    }
}
