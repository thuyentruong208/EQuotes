//
//  GrowingButton.swift
//  EQuotes
//
//  Created by Thuyên Trương on 30/08/2022.
//

import SwiftUI

struct RoundedRectangleButtonStyle: ButtonStyle {
    let color: Color
    let backgroundColor: Color

    init(color: Color = Color.black, backgroundColor: Color = Color.yellow) {
        self.color = color
        self.backgroundColor = backgroundColor
    }

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Spacer()
            configuration.label.foregroundColor(color)
            Spacer()
        }
        .padding(8)
        .background(backgroundColor.cornerRadius(8))
        .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}
