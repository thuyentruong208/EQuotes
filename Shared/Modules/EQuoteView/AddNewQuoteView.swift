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
                    QuoteItemRow(newQuoteContent.toQuoteItem(),
                                 show: .constant(true))
                    .border(Color.gray, width: 1)
                    .cornerRadius(10)
                    .frame(minWidth: 0, maxWidth: .infinity)


                    Spacer(minLength: 30)

                    BackQuoteItemRow(quoteItem: newQuoteContent.toQuoteItem(), show: .constant(true))
                        .border(Color.gray, width: 1)
                        .cornerRadius(10)
                        .frame(minWidth: 0, maxWidth: .infinity)
                }

                HStack {
                    textField($newQuoteContent.content)
                    Spacer(minLength: 30)

                    VStack {
                        textField($newQuoteContent.askContent)
                        textField($newQuoteContent.askImages)
                    }
                }

                Divider()
                    .frame(height: 3)
                    .background( Color(#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)))
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
                    .buttonStyle(RoundedRectangleButtonStyle(backgroundColor: Color.white))

                    Button {
                        submitNewQuote()

                    } label: {
                        Text("SUBMIT")
                    }
                    .buttonStyle(RoundedRectangleButtonStyle(backgroundColor: Color.white))
                }
                .padding(.top, 20)

            }
            .padding(50)
        }
        .frame(width: 700)

    }
}

extension AddNewQuoteView {

    func textField(_ content: Binding<String>) -> some View {
        TextEditor(text: content)
            .textFormatting(.textField)
            .padding()
            .border(colorTheme.primary, width: 1)
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(height: 180)
#if os(macOS)
            .modifier(ShortcutAddViewModifier(onExitCommand: {
                presentationMode.wrappedValue.dismiss()

            }, onRightDownCommand: {
                submitNewQuote()
            }))
#endif
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

struct ShortcutAddViewModifier: ViewModifier {
    let onExitCommand: () -> ()
    let onRightDownCommand: () -> ()

    func body(content: Content) -> some View {
        #if os(macOS)
        content
            .onExitCommand {
                onExitCommand()
            }
            .focusable()
            .onMoveCommand { direction in
                switch direction {
                case .right, .down:
                    onRightDownCommand()
                default:
                    break
                }
            }
        #else
        content
        #endif
    }
}
