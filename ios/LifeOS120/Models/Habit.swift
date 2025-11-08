//
//  Habit.swift
//  LifeOS-120
//
//  Habit tracking model
//

import Foundation

struct Habit: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    var habitName: String
    var description: String?
    var targetFrequency: String?
    var category: String?
    var isActive: Bool

    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case habitName = "habit_name"
        case description
        case targetFrequency = "target_frequency"
        case category
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct HabitCompletion: Codable, Identifiable {
    let id: UUID
    let habitId: UUID
    let userId: UUID
    let completionDate: Date
    var completed: Bool
    var notes: String?

    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case habitId = "habit_id"
        case userId = "user_id"
        case completionDate = "completion_date"
        case completed
        case notes
        case createdAt = "created_at"
    }
}
