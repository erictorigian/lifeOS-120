//
//  TodayViewModel.swift
//  LifeOS-120
//
//  Manages today's daily entry data
//

import Foundation
import SwiftUI
import Supabase

@MainActor
class TodayViewModel: ObservableObject {
    @Published var todayEntry: DailyEntry?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Local state for editing
    @Published var waterMl: Int = 0
    @Published var exerciseMinutes: Int = 0
    @Published var moodScore: Int = 5
    @Published var gratitudeEntry: String = ""

    private let supabase = SupabaseConfig.shared.client
    private var userId: UUID?

    init() {}

    // MARK: - Setup

    func setup(userId: UUID) {
        self.userId = userId
        Task {
            await fetchTodayEntry()
        }
    }

    // MARK: - Fetch Today's Entry

    func fetchTodayEntry() async {
        guard let userId = userId else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let today = Calendar.current.startOfDay(for: Date())

        do {
            // Try to fetch today's entry
            let entries: [DailyEntry] = try await supabase.database
                .from("daily_entries")
                .select()
                .eq("user_id", value: userId.uuidString)
                .eq("entry_date", value: ISO8601DateFormatter().string(from: today))
                .execute()
                .value

            if let entry = entries.first {
                todayEntry = entry
                // Update local state
                waterMl = entry.waterMl
                exerciseMinutes = entry.exerciseMinutes
                moodScore = entry.moodScore ?? 5
                gratitudeEntry = entry.gratitudeEntry ?? ""
            } else {
                // No entry for today, start fresh
                waterMl = 0
                exerciseMinutes = 0
                moodScore = 5
                gratitudeEntry = ""
            }

        } catch {
            errorMessage = "Failed to fetch today's entry: \(error.localizedDescription)"
            print("Error fetching today's entry: \(error)")
        }
    }

    // MARK: - Update Entry

    func saveEntry() async {
        guard let userId = userId else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let today = Calendar.current.startOfDay(for: Date())

        do {
            if let existingEntry = todayEntry {
                // Update existing entry
                let updated: DailyEntry = try await supabase.database
                    .from("daily_entries")
                    .update([
                        "water_ml": waterMl,
                        "exercise_minutes": exerciseMinutes,
                        "mood_score": moodScore,
                        "gratitude_entry": gratitudeEntry
                    ])
                    .eq("id", value: existingEntry.id.uuidString)
                    .single()
                    .execute()
                    .value

                todayEntry = updated

            } else {
                // Create new entry
                let newEntry: DailyEntry = try await supabase.database
                    .from("daily_entries")
                    .insert([
                        "user_id": userId.uuidString,
                        "entry_date": ISO8601DateFormatter().string(from: today),
                        "water_ml": waterMl,
                        "exercise_minutes": exerciseMinutes,
                        "mood_score": moodScore,
                        "gratitude_entry": gratitudeEntry
                    ])
                    .single()
                    .execute()
                    .value

                todayEntry = newEntry
            }

        } catch {
            errorMessage = "Failed to save entry: \(error.localizedDescription)"
            print("Error saving entry: \(error)")
        }
    }

    // MARK: - Quick Updates

    func addWater(_ amount: Int) {
        waterMl += amount
        Task {
            await saveEntry()
        }
    }

    func addExercise(_ minutes: Int) {
        exerciseMinutes += minutes
        Task {
            await saveEntry()
        }
    }

    func updateMood(_ score: Int) {
        moodScore = score
        Task {
            await saveEntry()
        }
    }

    func updateGratitude(_ text: String) {
        gratitudeEntry = text
        // Don't auto-save gratitude, let user tap save button
    }
}
