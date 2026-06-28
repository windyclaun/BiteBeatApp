import Foundation
import SwiftData

@Model
final class MealRecord {
    var mealTitle: String
    var mealDescription: String
    var mealPrice: String
    var mealLocation: String
    var mealCalories: String
    var mealCrazyFunDescription: String
    var mealSystemImage: String
    var mealGradientColors: [String]
    var mealImageUrl: String
    var mealImageQuery: String
    var resolvedImageURL: String?
    var selectedAt: Date

    init(meal: Meal, resolvedImageURL: String? = nil, selectedAt: Date = Date()) {
        self.mealTitle = meal.title
        self.mealDescription = meal.description
        self.mealPrice = meal.price
        self.mealLocation = meal.location
        self.mealCalories = meal.calories
        self.mealCrazyFunDescription = meal.crazyFunDescription
        self.mealSystemImage = meal.systemImage
        self.mealGradientColors = meal.gradientColors
        self.mealImageUrl = meal.imageUrl
        self.mealImageQuery = meal.imageQuery
        self.resolvedImageURL = resolvedImageURL
        self.selectedAt = selectedAt
    }

    var meal: Meal {
        Meal(
            title: mealTitle,
            price: mealPrice,
            location: mealLocation,
            calories: mealCalories,
            description: mealDescription,
            crazyFunDescription: mealCrazyFunDescription,
            systemImage: mealSystemImage,
            gradientColors: mealGradientColors,
            imageUrl: resolvedImageURL ?? mealImageUrl,
            imageQuery: mealImageQuery
        )
    }
}

enum MealRecordStore {
    private static let historyLimit = 20

    static func saveTodaySelection(_ meal: Meal, resolvedImageURL: String? = nil, in context: ModelContext) {
        deleteTodayRecords(in: context)
        context.insert(MealRecord(meal: meal, resolvedImageURL: resolvedImageURL))
        pruneHistory(in: context)
        try? context.save()
    }

    static func selectedMealToday(in context: ModelContext) -> Meal? {
        var descriptor = FetchDescriptor<MealRecord>(sortBy: [SortDescriptor(\.selectedAt, order: .reverse)])
        descriptor.fetchLimit = 1
        guard
            let latest = try? context.fetch(descriptor).first,
            Calendar.current.isDateInToday(latest.selectedAt)
        else {
            return nil
        }
        return latest.meal
    }

    static func resetTodaySelection(in context: ModelContext) {
        deleteTodayRecords(in: context)
        try? context.save()
    }

    private static func deleteTodayRecords(in context: ModelContext) {
        let all = (try? context.fetch(FetchDescriptor<MealRecord>())) ?? []
        for record in all where Calendar.current.isDateInToday(record.selectedAt) {
            context.delete(record)
        }
    }

    private static func pruneHistory(in context: ModelContext) {
        let descriptor = FetchDescriptor<MealRecord>(sortBy: [SortDescriptor(\.selectedAt, order: .reverse)])
        guard let all = try? context.fetch(descriptor), all.count > historyLimit else { return }
        for record in all[historyLimit...] {
            context.delete(record)
        }
    }
}
