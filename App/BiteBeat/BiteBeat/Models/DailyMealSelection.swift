import Foundation

public struct DailyMealSelection: Codable, Sendable {
    public let selectedAt: Date
    public let meal: Meal
}
