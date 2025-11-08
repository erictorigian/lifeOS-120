//
//  DailyEntry.swift
//  LifeOS-120
//
//  Daily health tracking entry model
//

import Foundation

struct DailyEntry: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let entryDate: Date

    // Hydration
    var waterMl: Int

    // Nutrition
    var calories: Int?
    var proteinG: Double?
    var carbsG: Double?
    var fatsG: Double?

    // Exercise
    var exerciseMinutes: Int
    var exerciseType: String?
    var steps: Int?

    // Sleep
    var sleepHours: Double?
    var sleepQuality: Int? // 1-10 scale

    // Mental/Emotional
    var gratitudeEntry: String?
    var coherencePracticeMinutes: Int
    var moodScore: Int? // 1-10 scale

    // Journal
    var notes: String?

    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case entryDate = "entry_date"
        case waterMl = "water_ml"
        case calories
        case proteinG = "protein_g"
        case carbsG = "carbs_g"
        case fatsG = "fats_g"
        case exerciseMinutes = "exercise_minutes"
        case exerciseType = "exercise_type"
        case steps
        case sleepHours = "sleep_hours"
        case sleepQuality = "sleep_quality"
        case gratitudeEntry = "gratitude_entry"
        case coherencePracticeMinutes = "coherence_practice_minutes"
        case moodScore = "mood_score"
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    // Default initializer for new entries
    init(
        id: UUID = UUID(),
        userId: UUID,
        entryDate: Date = Date(),
        waterMl: Int = 0,
        calories: Int? = nil,
        proteinG: Double? = nil,
        carbsG: Double? = nil,
        fatsG: Double? = nil,
        exerciseMinutes: Int = 0,
        exerciseType: String? = nil,
        steps: Int? = nil,
        sleepHours: Double? = nil,
        sleepQuality: Int? = nil,
        gratitudeEntry: String? = nil,
        coherencePracticeMinutes: Int = 0,
        moodScore: Int? = nil,
        notes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.entryDate = entryDate
        self.waterMl = waterMl
        self.calories = calories
        self.proteinG = proteinG
        self.carbsG = carbsG
        self.fatsG = fatsG
        self.exerciseMinutes = exerciseMinutes
        self.exerciseType = exerciseType
        self.steps = steps
        self.sleepHours = sleepHours
        self.sleepQuality = sleepQuality
        self.gratitudeEntry = gratitudeEntry
        self.coherencePracticeMinutes = coherencePracticeMinutes
        self.moodScore = moodScore
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
