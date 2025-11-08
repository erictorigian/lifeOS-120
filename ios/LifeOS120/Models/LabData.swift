//
//  LabData.swift
//  LifeOS-120
//
//  Lab test and biomarker data model
//

import Foundation

struct LabData: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let testDate: Date
    let testName: String

    var value: Double?
    var unit: String?
    var referenceRangeLow: Double?
    var referenceRangeHigh: Double?

    var labProvider: String?
    var notes: String?

    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case testDate = "test_date"
        case testName = "test_name"
        case value
        case unit
        case referenceRangeLow = "reference_range_low"
        case referenceRangeHigh = "reference_range_high"
        case labProvider = "lab_provider"
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    // Computed property to check if value is in range
    var isInRange: Bool? {
        guard let value = value,
              let low = referenceRangeLow,
              let high = referenceRangeHigh else {
            return nil
        }
        return value >= low && value <= high
    }

    // Status indicator
    var status: LabStatus {
        guard let isInRange = isInRange else { return .unknown }
        return isInRange ? .normal : .outOfRange
    }

    enum LabStatus {
        case normal
        case outOfRange
        case unknown
    }
}
