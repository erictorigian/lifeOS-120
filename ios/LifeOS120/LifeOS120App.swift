//
//  LifeOS120App.swift
//  LifeOS-120
//
//  Main app entry point
//

import SwiftUI

@main
struct LifeOS120App: App {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
