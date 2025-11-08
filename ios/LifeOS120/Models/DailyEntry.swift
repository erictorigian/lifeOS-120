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

    // Custom decoder to handle Supabase date formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        userId = try container.decode(UUID.self, forKey: .userId)

        // Decode dates with proper formatters
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let dateOnlyFormatter = DateFormatter()
        dateOnlyFormatter.dateFormat = "yyyy-MM-dd"

        // Entry date is just a date (no time)
        if let dateString = try? container.decode(String.self, forKey: .entryDate),
           let date = dateOnlyFormatter.date(from: dateString) {
            entryDate = date
        } else {
            entryDate = try container.decode(Date.self, forKey: .entryDate)
        }

        waterMl = try container.decode(Int.self, forKey: .waterMl)
        calories = try? container.decode(Int.self, forKey: .calories)
        proteinG = try? container.decode(Double.self, forKey: .proteinG)
        carbsG = try? container.decode(Double.self, forKey: .carbsG)
        fatsG = try? container.decode(Double.self, forKey: .fatsG)
        exerciseMinutes = try container.decode(Int.self, forKey: .exerciseMinutes)
        exerciseType = try? container.decode(String.self, forKey: .exerciseType)
        steps = try? container.decode(Int.self, forKey: .steps)
        sleepHours = try? container.decode(Double.self, forKey: .sleepHours)
        sleepQuality = try? container.decode(Int.self, forKey: .sleepQuality)
        gratitudeEntry = try? container.decode(String.self, forKey: .gratitudeEntry)
        coherencePracticeMinutes = (try? container.decode(Int.self, forKey: .coherencePracticeMinutes)) ?? 0
        moodScore = try? container.decode(Int.self, forKey: .moodScore)
        notes = try? container.decode(String.self, forKey: .notes)

        // Timestamps with time
        if let createdString = try? container.decode(String.self, forKey: .createdAt),
           let date = dateFormatter.date(from: createdString) {
            createdAt = date
        } else {
            createdAt = try container.decode(Date.self, forKey: .createdAt)
        }

        if let updatedString = try? container.decode(String.self, forKey: .updatedAt),
           let date = dateFormatter.date(from: updatedString) {
            updatedAt = date
        } else {
            updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        }
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
