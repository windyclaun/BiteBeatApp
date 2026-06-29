import CoreLocation
import MapKit

public struct NearbyRestaurant: Identifiable, Sendable, Hashable {
    public let id: UUID
    public let name: String
    public let address: String
    public let coordinate: CLLocationCoordinate2D
    public let distanceInMeters: Double
    public let mapItemIdentifier: String?

    public init(
        id: UUID = UUID(),
        name: String,
        address: String,
        coordinate: CLLocationCoordinate2D,
        distanceInMeters: Double,
        mapItemIdentifier: String? = nil
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.coordinate = coordinate
        self.distanceInMeters = distanceInMeters
        self.mapItemIdentifier = mapItemIdentifier
    }

    public static func == (lhs: NearbyRestaurant, rhs: NearbyRestaurant) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

public struct RestaurantDishes: Identifiable, Sendable, Hashable {
    public let id: UUID
    public let restaurant: NearbyRestaurant
    public let dishes: [Meal]

    public init(restaurant: NearbyRestaurant, dishes: [Meal]) {
        self.id = restaurant.id
        self.restaurant = restaurant
        self.dishes = dishes
    }
}
