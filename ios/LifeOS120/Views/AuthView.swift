//
//  AuthView.swift
//  LifeOS-120
//
//  Authentication screen for login and signup
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var fullName = ""
    @State private var isSignUp = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // App Logo/Title
                VStack(spacing: 12) {
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(.white)

                    Text("LifeOS-120")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Live to 120 Years")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                }

                Spacer()

                // Auth Form
                VStack(spacing: 20) {
                    // Toggle between Login/Signup
                    Picker("", selection: $isSignUp) {
                        Text("Login").tag(false)
                        Text("Sign Up").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Form Fields
                    VStack(spacing: 16) {
                        if isSignUp {
                            TextField("Full Name", text: $fullName)
                                .textContentType(.name)
                                .autocapitalization(.words)
                                .textFieldStyle(RoundedTextFieldStyle())
                        }

                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .textFieldStyle(RoundedTextFieldStyle())

                        SecureField("Password", text: $password)
                            .textContentType(isSignUp ? .newPassword : .password)
                            .textFieldStyle(RoundedTextFieldStyle())
                    }
                    .padding(.horizontal)

                    // Error Message
                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }

                    // Submit Button
                    Button(action: handleAuth) {
                        HStack {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text(isSignUp ? "Sign Up" : "Login")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundStyle(Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(authViewModel.isLoading || !isFormValid)
                    .opacity(isFormValid ? 1.0 : 0.6)
                    .padding(.horizontal)
                }
                .padding(.vertical, 32)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                )
                .padding(.horizontal, 24)

                Spacer()
            }
        }
    }

    private var isFormValid: Bool {
        if isSignUp {
            return !email.isEmpty && !password.isEmpty && !fullName.isEmpty && password.count >= 6
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }

    private func handleAuth() {
        Task {
            if isSignUp {
                await authViewModel.signUp(
                    email: email,
                    password: password,
                    fullName: fullName.isEmpty ? nil : fullName
                )
            } else {
                await authViewModel.signIn(
                    email: email,
                    password: password
                )
            }
        }
    }
}

// MARK: - Custom TextField Style

struct RoundedTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(12)
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}
