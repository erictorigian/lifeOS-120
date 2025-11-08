//
//  MainTabView.swift
//  LifeOS-120
//
//  Main navigation structure for the app
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab (Dashboard)
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            // Today Tab (Data Entry)
            TodayView()
                .tabItem {
                    Label("Track", systemImage: "plus.circle.fill")
                }
                .tag(1)

            // Profile Tab
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
                .tag(2)
        }
        .tint(.blue)
    }
}

// MARK: - Profile View (Placeholder)

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            List {
                Section {
                    if let profile = authViewModel.currentProfile {
                        LabeledContent("Email", value: profile.email)
                        if let fullName = profile.fullName {
                            LabeledContent("Name", value: fullName)
                        }
                        if let age = profile.age {
                            LabeledContent("Age", value: "\(age)")
                        }
                        LabeledContent("Target Age", value: "\(profile.targetAge)")
                        if let yearsToGo = profile.yearsToTarget {
                            LabeledContent("Years to Goal", value: "\(yearsToGo)")
                        }
                    }
                } header: {
                    Text("Profile Information")
                }

                Section {
                    Button(role: .destructive) {
                        Task {
                            await authViewModel.signOut()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text("Sign Out")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
