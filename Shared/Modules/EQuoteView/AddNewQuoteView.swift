//
//  AddNewQuoteView.swift
//  EQuotes
//
//  Created by Thuyên Trương on 30/08/2022.
//

import SwiftUI

struct AddNewQuoteView: View {

    @Environment(\.injected) private var injected: DIContainer
    @Environment(\.presentationMode) var presentationMode

    @StateObject var newQuoteContent = NewQuoteContent()
    @State var addQuoteSuccess: Bool = false

    init(quoteItem: QuoteItem? = nil) {
        self._newQuoteContent = StateObject(wrappedValue: NewQuoteContent(quoteItem: quoteItem))
    }

    var body: some View {
        Screen(colorTheme.secondaryBackground) {
            VStack(alignment: .leading) {

                HStack {
                    QuoteItemRow(quoteItem: newQuoteContent.toQuoteItem())
                        .border(Color.gray, width: 1)
                        .cornerRadius(10)
                        .frame(minWidth: 0, maxWidth: .infinity)


                    Spacer(minLength: 30)

                    BackQuoteItemRow(content: newQuoteContent.toQuoteItem().ask ?? "")
                        .border(Color.gray, width: 1)
                        .cornerRadius(10)
                        .frame(minWidth: 0, maxWidth: .infinity)
                }

                Text("Content")
                    .font(.headline)

                HStack {
                    TextEditor(text: $newQuoteContent.content)
                        .textFormatting(.textField)
                        .padding()
                        .border(colorTheme.primary, width: 1)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 180)

                    Spacer(minLength: 30)

                    TextEditor(text: $newQuoteContent.askContent)
                        .textFormatting(.textField)
                        .padding()
                        .border(colorTheme.primary, width: 1)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 180)
                }

//                TextEditor(text: $newQuoteContent.content)
//                    .textFormatting(.textField)
//                    .padding()
//                    .border(colorTheme.primary, width: 1)
//                    .frame(height: 180)
//                #if os(macOS)
//                    .onExitCommand {
////                        submitNewQuote()
//                        //                        presentationMode.wrappedValue.dismiss()
//                    }
//                    .focusable()
//                    .onMoveCommand { direction in
////                        switch direction {
////                        case .right, .down:
//////                            submitNewQuote()
////                        default:
////                            break
////                        }
//                    }
//                #endif

                Divider()
                    .frame(height: 3)
                    .background(Color.orange)
                    .padding(.top, 30)

                HStack(spacing: 30) {

                    if addQuoteSuccess {
                        Image(systemName: "icloud.and.arrow.up.fill")
                            .resizable()
                            .foregroundColor(Color.green)
                            .scaledToFit()
                            .frame(width: 20, height: 20)

                    }

                    Spacer(minLength: 250)

                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("END")
                            .bold()
                            .foregroundColor(Color.red)
                    }
                    .buttonStyle(GrowingButton())

                    Button {
                        submitNewQuote()

                    } label: {
                        Text("SUBMIT")
                    }
                    .buttonStyle(GrowingButton())
                }
                .padding(.top, 20)

            }
            .padding(50)
        }
        .frame(width: 700)

    }
}

extension AddNewQuoteView {
    func submitNewQuote() {
        let quoteItem = newQuoteContent.toQuoteItem()

        func doneCreateOrUpdate() {
            addQuoteSuccess = true
            newQuoteContent.clear()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                addQuoteSuccess = false
            }
        }

        if quoteItem.id == nil { // Add
            injected.interactors.quotesInteractor
                .addQuote(item: quoteItem) { (result) in
                    guard result.isSuccess(ifFailure: { error in
                        injected.interactors.eventsInteractor.systemError(error: error, alertUser: true)

                    }) else { return }

                    doneCreateOrUpdate()
                }

        } else { // Edit
            injected.interactors.quotesInteractor
                .updateQuote(item: quoteItem) { result in
                    guard result.isSuccess(ifFailure: { error in
                        injected.interactors.eventsInteractor.systemError(error: error, alertUser: true)

                    }) else { return }

                    doneCreateOrUpdate()
                }
        }
    }
}

struct AddNewQuote_Previews: PreviewProvider {
    static var previews: some View {
        AddNewQuoteView()
    }
}
