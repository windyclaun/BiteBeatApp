import Foundation

public struct DailyMealSelection: Codable, Sendable {
    public let selectedAt: Date
    public let meal: Meal
}

public enum DailyMealSelectionStore {
    private static let selectedMealKey = "dailySelectedMeal"
    private static let mealHistoryKey = "mealSelectionHistory"
    private static let calendar = Calendar.current

    public static func save(_ meal: Meal) {
        let selection = DailyMealSelection(selectedAt: Date(), meal: meal)

        guard let data = try? JSONEncoder().encode(selection) else { return }
        UserDefaults.standard.set(data, forKey: selectedMealKey)
        saveToHistory(selection)
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

    public static func recentSelections(limit: Int = 3) -> [DailyMealSelection] {
        loadHistory()
            .sorted { $0.selectedAt > $1.selectedAt }
            .prefix(limit)
            .map { $0 }
    }

    private static func saveToHistory(_ selection: DailyMealSelection) {
        var history = loadHistory()
        history.removeAll { calendar.isDate($0.selectedAt, inSameDayAs: selection.selectedAt) }
        history.insert(selection, at: 0)

        guard let data = try? JSONEncoder().encode(Array(history.prefix(20))) else { return }
        UserDefaults.standard.set(data, forKey: mealHistoryKey)
    }

    private static func loadHistory() -> [DailyMealSelection] {
        guard
            let data = UserDefaults.standard.data(forKey: mealHistoryKey),
            let history = try? JSONDecoder().decode([DailyMealSelection].self, from: data)
        else {
            return []
        }

        return history
    }

    public static func resetTodaySelection() {
        UserDefaults.standard.removeObject(forKey: selectedMealKey)
        
        // Also remove today's entry from the meal history to keep it fully in sync
        var history = loadHistory()
        history.removeAll { calendar.isDateInToday($0.selectedAt) }
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: mealHistoryKey)
        }
    }
}

