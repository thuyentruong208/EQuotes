//
//  Store.swift
//  EQuotes
//
//  Created by Thuyên Trương on 30/08/2022.
//

import SwiftUI
import Combine

typealias Store<State> = CurrentValueSubject<State, Never>
