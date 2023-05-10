//
//  DepotBrowserApp.swift
//  DepotBrowser
//
//  Created by Martin Imobersteg on 26.04.23.
//

import SwiftUI
import ComposableArchitecture

@main
struct DepotBrowserApp: App {
    var body: some Scene {
        WindowGroup {
            DepotBrowserView(store: Store(initialState: DepotBrowser.State(), reducer: DepotBrowser()))
        }
    }
}
