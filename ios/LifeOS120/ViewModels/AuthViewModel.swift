//
//  AuthViewModel.swift
//  LifeOS-120
//
//  Handles authentication state and operations
//

import Foundation
import SwiftUI
import Supabase

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var currentProfile: Profile?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let supabase = SupabaseConfig.shared.client
    private let keychain = KeychainHelper.shared

    init() {
        // Check for existing session on initialization
        Task {
            await checkSession()
        }
    }

    // MARK: - Session Management

    func checkSession() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Try to get current session from Supabase
            let session = try await supabase.auth.session
            currentUser = session.user
            isAuthenticated = true

            // Fetch user profile
            await fetchProfile()

            // Save tokens to keychain
            _ = keychain.saveAccessToken(session.accessToken)
            _ = keychain.saveRefreshToken(session.refreshToken)
            _ = keychain.saveUserId(session.user.id.uuidString)

        } catch {
            // No valid session, user needs to login
            isAuthenticated = false
            currentUser = nil
            currentProfile = nil
        }
    }

    // MARK: - Sign Up

    func signUp(email: String, password: String, fullName: String?) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await supabase.auth.signUp(
                email: email,
                password: password,
                data: fullName.map { ["full_name": .string($0)] }
            )

            currentUser = response.user
            isAuthenticated = true

            // Save tokens
            if let session = response.session {
                _ = keychain.saveAccessToken(session.accessToken)
                _ = keychain.saveRefreshToken(session.refreshToken)
                _ = keychain.saveUserId(session.user.id.uuidString)
            }

            // Fetch profile
            await fetchProfile()

        } catch let error as NSError {
            errorMessage = error.localizedDescription
            print("Sign up error: \(error)")
        }
    }

    // MARK: - Sign In

    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let session = try await supabase.auth.signIn(
                email: email,
                password: password
            )

            currentUser = session.user
            isAuthenticated = true

            // Save tokens
            _ = keychain.saveAccessToken(session.accessToken)
            _ = keychain.saveRefreshToken(session.refreshToken)
            _ = keychain.saveUserId(session.user.id.uuidString)

            // Fetch profile
            await fetchProfile()

        } catch let error as NSError {
            errorMessage = error.localizedDescription
            print("Sign in error: \(error)")
        }
    }

    // MARK: - Sign Out

    func signOut() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await supabase.auth.signOut()
        } catch {
            print("Sign out error: \(error)")
        }

        // Clear local state
        isAuthenticated = false
        currentUser = nil
        currentProfile = nil
        keychain.clearAuthData()
    }

    // MARK: - Profile Management

    private func fetchProfile() async {
        guard let userId = currentUser?.id else { return }

        do {
            let profile: Profile = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: userId.uuidString)
                .single()
                .execute()
                .value

            currentProfile = profile

        } catch {
            print("Error fetching profile: \(error)")
            // Profile might not exist yet, which is okay for new users
        }
    }

    func updateProfile(_ profile: Profile) async {
        guard let userId = currentUser?.id else { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let _: Profile = try await supabase
                .from("profiles")
                .update(profile)
                .eq("id", value: userId.uuidString)
                .single()
                .execute()
                .value

            currentProfile = profile

        } catch {
            errorMessage = "Failed to update profile: \(error.localizedDescription)"
            print("Error updating profile: \(error)")
        }
    }
}
