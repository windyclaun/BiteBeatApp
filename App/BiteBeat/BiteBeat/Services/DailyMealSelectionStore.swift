import Foundation

public struct DailyMealSelection: Codable, Sendable {
    public let selectedAt: Date
    public let meal: Meal
}

public enum DailyMealSelectionStore {
    private static let selectedMealKey = "dailySelectedMeal"
    private static let calendar = Calendar.current

    public static func save(_ meal: Meal) {
        let selection = DailyMealSelection(selectedAt: Date(), meal: meal)

        guard let data = try? JSONEncoder().encode(selection) else { return }
        UserDefaults.standard.set(data, forKey: selectedMealKey)
    }

    public static func selectedMealForToday() -> Meal? {
        guard
            let data = UserDefaults.standard.data(forKey: selectedMealKey),
            let selection = try? JSONDecoder().decode(DailyMealSelection.self, from: data),
            calendar.isDateInToday(selection.selectedAt)
        else {
            return nil
        }

        return selection.meal
    }
}
