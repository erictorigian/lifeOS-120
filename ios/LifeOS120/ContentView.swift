//
//  ContentView.swift
//  LifeOS-120
//
//  Main content view that handles routing based on authentication state
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                AuthView()
            }
        }
        .onAppear {
            Task {
                await authViewModel.checkSession()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
