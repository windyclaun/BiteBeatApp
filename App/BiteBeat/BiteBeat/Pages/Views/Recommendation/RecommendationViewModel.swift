import SwiftUI
import MapKit
import Observation
import BiteBeatMusic

@Observable
@MainActor
public final class RecommendationViewModel {
    public let vibeName: String
    public let vibeDescription: String
    public let mainMeal: Meal
    public let alternatives: [Meal]
    public let restaurants: [RestaurantDishes]
    public let isMapsFlow: Bool

    public var choseNay = false
    public var selectedAlternative: Meal?
    public var drillInRestaurantIndex: Int?
    public var mapPosition: MapCameraPosition = .automatic

    init(data: RecommendationData) {
        self.vibeName = data.vibeName
        self.vibeDescription = data.vibeDescription
        self.mainMeal = data.mainMeal
        self.alternatives = data.alternatives
        self.restaurants = data.restaurants
        self.isMapsFlow = data.isMapsFlow
    }

    public var drillInRestaurant: RestaurantDishes? {
        guard let idx = drillInRestaurantIndex, restaurants.indices.contains(idx) else { return nil }
        return restaurants[idx]
    }

    public func openDrillIn(for restaurant: RestaurantDishes) {
        if let idx = restaurants.firstIndex(where: { $0.id == restaurant.id }) {
            drillInRestaurantIndex = idx
        }
    }

    public func closeDrillIn() {
        drillInRestaurantIndex = nil
    }

    public func toggleShowAlternatives(show: Bool) {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
            choseNay = show
            if !show {
                selectedAlternative = nil
            }
        }
    }

    public func selectAlternativeCard(_ meal: Meal) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
            selectedAlternative = meal
        }
    }

    public func resetToMainSelection() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
            choseNay = false
            selectedAlternative = nil
        }
    }

    public func openInMaps(_ meal: Meal) async {
        await MapsHelper.openInMaps(for: meal)
    }
}
