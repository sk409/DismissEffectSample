//
//  TestApp.swift
//  Test
//
//  Created by 小林聖人 on 2023/06/05.
//

import ComposableArchitecture
import SwiftUI

@main
struct TestApp: App {
    let store = Store(initialState: A.State(), reducer: A())
    
    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
