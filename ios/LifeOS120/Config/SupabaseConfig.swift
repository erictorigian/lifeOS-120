//
//  SupabaseConfig.swift
//  LifeOS-120
//
//  Supabase client configuration
//

import Foundation
import Supabase

class SupabaseConfig {
    static let shared = SupabaseConfig()

    // MARK: - Configuration
    private let supabaseURL = URL(string: "https://lvzqnfleelxiwmtpwxrr.supabase.co")!
    private let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx2enFuZmxlZWx4aXdtdHB3eHJyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI2MTY4NTgsImV4cCI6MjA3ODE5Mjg1OH0.jJmkWmQSgTuklsg0XukqW3ymkM6oltfZdratpM65KKw"

    // MARK: - Client
    lazy var client: SupabaseClient = {
        SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseAnonKey
        )
    }()

    private init() {}
}

// MARK: - Convenience accessor
extension SupabaseConfig {
    var auth: AuthClient {
        client.auth
    }
}
