//
//  HealthScore.swift
//  LifeOS-120
//
//  Health scoring system and trend calculation
//

import Foundation

struct HealthScore {
    let totalScore: Int
    let waterScore: Int
    let exerciseScore: Int
    let moodScore: Int
    let gratitudeScore: Int
    let date: Date

    // Scoring weights (total = 100 points)
    static let waterMaxPoints = 20
    static let exerciseMaxPoints = 30
    static let moodMaxPoints: Double = 30.0
    static let gratitudeMaxPoints = 20

    // Targets
    static let waterTarget = 2000 // ml
    static let exerciseTarget = 30 // minutes
    static let moodTarget = 10.0 // max mood

    init(from entry: DailyEntry) {
        self.date = entry.entryDate

        // Water score (0-20 points)
        // 2000ml = 20 points, pro-rated
        let waterPercentage = min(Double(entry.waterMl) / Double(Self.waterTarget), 1.0)
        self.waterScore = Int(waterPercentage * Double(Self.waterMaxPoints))

        // Exercise score (0-30 points)
        // 30 minutes = 30 points, pro-rated
        let exercisePercentage = min(Double(entry.exerciseMinutes) / Double(Self.exerciseTarget), 1.0)
        self.exerciseScore = Int(exercisePercentage * Double(Self.exerciseMaxPoints))

        // Mood score (0-30 points)
        // Mood is 1-10, convert to 0-30
        if let mood = entry.moodScore {
            self.moodScore = Int((Double(mood) / Self.moodTarget) * Self.moodMaxPoints)
        } else {
            self.moodScore = 0
        }

        // Gratitude score (0-20 points)
        // Has entry = 20 points, empty = 0
        if let gratitude = entry.gratitudeEntry, !gratitude.isEmpty {
            self.gratitudeScore = Self.gratitudeMaxPoints
        } else {
            self.gratitudeScore = 0
        }

        // Total score
        self.totalScore = waterScore + exerciseScore + moodScore + gratitudeScore
    }

    // Score rating
    var rating: String {
        switch totalScore {
        case 90...100: return "Excellent"
        case 75...89: return "Great"
        case 60...74: return "Good"
        case 40...59: return "Fair"
        default: return "Needs Work"
        }
    }

    var ratingEmoji: String {
        switch totalScore {
        case 90...100: return "🌟"
        case 75...89: return "💪"
        case 60...74: return "👍"
        case 40...59: return "📈"
        default: return "🎯"
        }
    }

    var color: String {
        switch totalScore {
        case 90...100: return "green"
        case 75...89: return "blue"
        case 60...74: return "orange"
        default: return "red"
        }
    }
}

// MARK: - Trend Calculation

struct HealthTrend {
    let averageScore: Double
    let change: Double // compared to previous period
    let days: Int

    var changeDescription: String {
        if change > 5 {
            return "📈 Up \(Int(change)) pts"
        } else if change < -5 {
            return "📉 Down \(Int(abs(change))) pts"
        } else {
            return "➡️ Steady"
        }
    }

    var isImproving: Bool {
        change > 0
    }
}

extension Array where Element == HealthScore {
    func calculateTrend() -> HealthTrend? {
        guard !isEmpty else { return nil }

        let average = Double(reduce(0) { $0 + $1.totalScore }) / Double(count)

        // Calculate change from first half to second half
        let midpoint = count / 2
        if count >= 4 {
            let firstHalf = prefix(midpoint)
            let secondHalf = suffix(count - midpoint)

            let firstAvg = Double(firstHalf.reduce(0) { $0 + $1.totalScore }) / Double(firstHalf.count)
            let secondAvg = Double(secondHalf.reduce(0) { $0 + $1.totalScore }) / Double(secondHalf.count)

            return HealthTrend(
                averageScore: average,
                change: secondAvg - firstAvg,
                days: count
            )
        }

        return HealthTrend(averageScore: average, change: 0, days: count)
    }
}
