import Foundation

public enum HomeRoute: Hashable {
    case recommendation(RecommendationData)
    case ending(Meal)
}
