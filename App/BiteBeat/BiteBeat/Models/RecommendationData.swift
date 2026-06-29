import Foundation

public struct RecommendationData: Hashable {
    public let vibeName: String
    public let vibeDescription: String
    public let mainMeal: Meal
    public let alternatives: [Meal]
    public let restaurants: [RestaurantDishes]
    public let isMapsFlow: Bool

    public init(
        vibeName: String,
        vibeDescription: String,
        mainMeal: Meal,
        alternatives: [Meal],
        restaurants: [RestaurantDishes] = [],
        isMapsFlow: Bool = false
    ) {
        self.vibeName = vibeName
        self.vibeDescription = vibeDescription
        self.mainMeal = mainMeal
        self.alternatives = alternatives
        self.restaurants = restaurants
        self.isMapsFlow = isMapsFlow
    }
}
