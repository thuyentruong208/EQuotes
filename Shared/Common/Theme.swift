//
//  Theme.swift
//  EQuotes
//
//  Created by Thuyên Trương on 30/08/2022.
//

import SwiftUI

let colorTheme = ColorTheme()

enum FontStyle {
    case header
    case textField
    case primaryText
    case primaryTextWith(Color)
    case seconddaryText
    case secondaryTextWith(Color)
}

struct TextViewModifier: ViewModifier {

    let font: Font
    let foregroundColor: Color
    let backgroundColor: Color

    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
    }
}

extension View {
    func textFormatting(_ fontStyle: FontStyle) -> some View {
        switch fontStyle {
        case .header:
            return modifier(
                TextViewModifier(
                    font: .custom("HelveticaNeue", size: 16),
                    foregroundColor: colorTheme.primary,
                    backgroundColor: Color.clear))

        case .textField:
            return modifier(
                TextViewModifier(
                    font: .custom("HelveticaNeue", size: 16),
                    foregroundColor: colorTheme.textField,
                    backgroundColor: colorTheme.textFieldBackground))

        case .primaryText:
            return textFormatting(.primaryTextWith( colorTheme.boxTextColor))

        case let .primaryTextWith(color):
            var size: CGFloat = 18

            #if os(macOS)
            size = 22
            #endif

            return modifier(
                TextViewModifier(
                    font: .custom("Avenir Next Condensed", size: size),
                    foregroundColor: color,
                    backgroundColor: Color.clear))

        case .seconddaryText:
            return textFormatting(.secondaryTextWith( colorTheme.boxTextColor))

        case let .secondaryTextWith(color):
            return modifier(
                TextViewModifier(
                    font: .callout,
                    foregroundColor: color,
                    backgroundColor: Color.clear))


        }

    }

}

struct Theme {


}

struct ColorTheme {
    let background = Color("BackgroundColor")
    let accent = Color("AccentColor")
    let primary = Color("PrimaryColor")
    let textField = Color("TextFieldColor")
    let textFieldBackground = Color("TextFieldBackgroundColor")
    let secondaryBackground = Color("SecondaryBackgroundColor")
    let boxTextColor = Color("BoxTextColor")
}
