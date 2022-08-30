//
//  Screen.swift
//  EQuotes
//
//  Created by Thuyên Trương on 30/08/2022.
//

import SwiftUI

struct Screen<Content: View>: View {
    let content: () -> Content

    var body: some View {
        ZStack {
//            Color..edgesIgnoringSafeArea(.all)
            content()
        }
    }
}
