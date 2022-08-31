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
    @State var editQuoteView: QuoteItem?
    @State var showBackFaceQuoteItems = Set<String>()
    @State var backDegree = 0.0
    @State var frontDegree = -90.0

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            colorTheme.background.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: true) {
                HStack {
                    Image("image")
                        .resizable()
                        .frame(width: 120, height: 120)

                    Spacer()

                    HStack {
                        VStack {
                            Text("Learn Mode")

                            Toggle("", isOn: $learnMode)
                                .toggleStyle(SwitchToggleStyle())
                        }

#if os(macOS)
                        addButton
                            .padding(.top, 20)
#endif


                    }
                }

                if learnMode {
                    LearnView()
                } else {
                    LazyVStack(alignment: .center, spacing: 20) {
                        ForEach(quoteState.quotesLoadable.value ?? []) { (quoteItem) in
                            quoteItemView(quoteItem: quoteItem)
                        }
                    }
                    .padding()
                }

            }
            .sheet(item: $editQuoteView, content: { quoteItem in
                AddNewQuoteView(quoteItem: quoteItem)
            })
            .overlay(
                VStack(alignment: .trailing) {


                    //                    Toggle("", isOn: $random)
                    //                        .foregroundColor(Color.pink)
                    //                        .toggleStyle(SwitchToggleStyle(tint: Color.pink))
                    //                        .padding(20)
                    //#if os(macOS)

                    //#endif
                }



                //                Button {
                //                    Reminder.shared
                //                        .scheduleReminder(samples: viewModel.items)
                //
                //                } label: {
                //                    Image(systemName: "bell.circle.fill")
                //                        .frame(width: 64, height: 64)
                //                }
                , alignment: .topTrailing
            )

        }
        .ignoresSafeArea(.all, edges: .bottom)
        .onAppear {
            injected.interactors.quotesInteractor.listenItems()
        }
        .onDisappear {
            //            quotesListener?.remove()
        }
        //        .onReceive(noticeQuoteItemIDUpdate) {
        //            self.noticeQuoteItemID = $0
        //        }
    }
}

extension EQuoteView {

    var addButton: some View {
        Button(action: {
            showAddQuoteView.toggle()

        }, label: {
            Label("Add", systemImage: "plus.message.fill")
        })
        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))

        .buttonStyle(.borderless)
        .tint(.pink)
        .foregroundColor(.white)
        .cornerRadius(40)
        .background(Color("Color1"))
        //            .padding()
        //            .buttonStyle(BlueButtonStyle())
        .sheet(isPresented: $showAddQuoteView) {
            AddNewQuoteView()
        }
    }

    func quoteItemView(quoteItem: QuoteItem) -> some View {
        let front = !showBackFaceQuoteItems.contains(quoteItem.id ?? "")

        return ZStack {
                QuoteItemRow(quoteItem, editQuoteView: $editQuoteView, show: .constant(front))
                        .frame(maxWidth: 500)

//                    .onTapGesture {
//                        flipCard(quoteItem, !front)
//                    }

                BackQuoteItemRow(content: quoteItem.ask ?? "", show: .constant(!front))
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

extension EQuoteView {


}

struct EQuoteView_Previews: PreviewProvider {
    static var previews: some View {
        EQuoteView()
    }
}
