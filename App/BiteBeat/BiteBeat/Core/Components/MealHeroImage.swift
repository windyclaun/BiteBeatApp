import SwiftUI

public struct MealHeroImage: View {
    public let meal: Meal
    public let size: CGFloat

    public init(meal: Meal, size: CGFloat = 200) {
        self.meal = meal
        self.size = size
    }

    public var body: some View {
        FoodImageView(
            mealTitle: meal.title,
            wikipediaQuery: meal.wikipediaSearchQuery,
            fallbackUrl: meal.imageUrl
        )
        .frame(width: size, height: size)
        .clipShape(Circle())
        .shadowStyle(radius: 8, y: 4, opacity: 0.12)
    }
}

#Preview {
    MealHeroImage(
        meal: Meal(title: "Nasi Goreng", price: "Rp 25.000", location: "Warung", calories: "500 kcal", description: "Delicious"),
        size: 200
    )
}
