//
//  HomeViewModel.swift
//  LifeOS-120
//
//  Home dashboard view model
//

import Foundation
import SwiftUI
import Supabase

@MainActor
class HomeViewModel: ObservableObject {
    @Published var todayScore: HealthScore?
    @Published var yesterdayScore: HealthScore?
    @Published var weeklyTrend: HealthTrend?
    @Published var monthlyTrend: HealthTrend?
    @Published var currentStreak: Int = 0
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let supabase = SupabaseConfig.shared.client
    private var userId: UUID?

    init() {}

    // MARK: - Setup

    func setup(userId: UUID) {
        self.userId = userId
        Task {
            await fetchDashboardData()
        }
    }

    // MARK: - Fetch Dashboard Data

    func fetchDashboardData() async {
        guard let userId = userId else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
            let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: today)!
            let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: today)!

            // Fetch last 30 days of entries
            let entries: [DailyEntry] = try await supabase
                .from("daily_entries")
                .select()
                .eq("user_id", value: userId.uuidString)
                .gte("entry_date", value: ISO8601DateFormatter().string(from: thirtyDaysAgo))
                .order("entry_date", ascending: false)
                .execute()
                .value

            // Calculate scores
            let scores = entries.map { HealthScore(from: $0) }

            // Today's score
            todayScore = scores.first { calendar.isDate($0.date, inSameDayAs: today) }

            // Yesterday's score
            yesterdayScore = scores.first { calendar.isDate($0.date, inSameDayAs: yesterday) }

            // Weekly trend (last 7 days)
            let weeklyScores = scores.filter { $0.date >= sevenDaysAgo }
            weeklyTrend = weeklyScores.calculateTrend()

            // Monthly trend (last 30 days)
            monthlyTrend = scores.calculateTrend()

            // Calculate current streak
            currentStreak = calculateStreak(from: entries)

        } catch {
            errorMessage = "Failed to load dashboard: \(error.localizedDescription)"
            print("Error loading dashboard: \(error)")
        }
    }

    // MARK: - Streak Calculation

    private func calculateStreak(from entries: [DailyEntry]) -> Int {
        guard !entries.isEmpty else { return 0 }

        let calendar = Calendar.current
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())

        // Sort by date descending
        let sortedEntries = entries.sorted { $0.entryDate > $1.entryDate }

        for entry in sortedEntries {
            let entryDate = calendar.startOfDay(for: entry.entryDate)

            if calendar.isDate(entryDate, inSameDayAs: currentDate) {
                // Check if entry has meaningful data
                if entry.waterMl > 0 || entry.exerciseMinutes > 0 || entry.moodScore != nil {
                    streak += 1
                    currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
                } else {
                    break
                }
            } else {
                // Gap in streak
                break
            }
        }

        return streak
    }

    // MARK: - Motivational Message

    var motivationalMessage: String {
        guard let todayScore = todayScore else {
            return "Start your day strong! 💪"
        }

        switch todayScore.totalScore {
        case 90...100:
            return "You're crushing it today! 🌟"
        case 75...89:
            return "Great progress! Keep it up! 💪"
        case 60...74:
            return "Good work! You're on track! 👍"
        case 40...59:
            return "You've got this! Keep going! 📈"
        default:
            if let yesterday = yesterdayScore, todayScore.totalScore > yesterday.totalScore {
                return "Better than yesterday! 📈"
            }
            return "Every step counts! 🎯"
        }
    }

    // MARK: - Quick Stats

    var completionPercentage: Double {
        guard let todayScore = todayScore else { return 0.0 }
        return Double(todayScore.totalScore) / 100.0
    }

    var scoreChange: Int? {
        guard let today = todayScore, let yesterday = yesterdayScore else { return nil }
        return today.totalScore - yesterday.totalScore
    }

    var scoreChangeDescription: String? {
        guard let change = scoreChange else { return nil }
        if change > 0 {
            return "+\(change) from yesterday"
        } else if change < 0 {
            return "\(change) from yesterday"
        } else {
            return "Same as yesterday"
        }
    }
}
