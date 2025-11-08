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
            // Today Tab
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "calendar")
                }
                .tag(0)

            // Profile Tab (placeholder for future)
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
                .tag(1)
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
