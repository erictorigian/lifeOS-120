//
//  Profile.swift
//  LifeOS-120
//
//  User profile model
//

import Foundation

struct Profile: Codable, Identifiable {
    let id: UUID
    let email: String
    var fullName: String?
    var dateOfBirth: Date?
    var targetAge: Int
    var heightCm: Double?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName = "full_name"
        case dateOfBirth = "date_of_birth"
        case targetAge = "target_age"
        case heightCm = "height_cm"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    // Computed property for age
    var age: Int? {
        guard let dateOfBirth = dateOfBirth else { return nil }
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        return ageComponents.year
    }

    // Years remaining to target
    var yearsToTarget: Int? {
        guard let age = age else { return nil }
        return targetAge - age
    }
}
