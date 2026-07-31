import Foundation
import SwiftUI

public struct Meal: Identifiable, Hashable, Codable, Sendable {
    public let id: UUID
    public let title: String
    public let price: String
    public let location: String
    public let calories: String
    public let description: String
    public let imageUrl: String
    public let crazyFunDescription: String

    public let realRestaurantName: String?
    public let restaurantAddress: String?
    public let latitude: Double?
    public let longitude: Double?
    public let distanceInMeters: Double?
    public let mapItemIdentifier: String?

    nonisolated public static let defaultCrazyFunDescription = "Warning - this meal may trigger spontaneous shoulder dancing."

    nonisolated public init(
        title: String,
        price: String,
        location: String,
        calories: String,
        description: String,
        crazyFunDescription: String = Meal.defaultCrazyFunDescription,
        imageUrl: String = "",
        realRestaurantName: String? = nil,
        restaurantAddress: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        distanceInMeters: Double? = nil,
        mapItemIdentifier: String? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.price = price
        self.location = location
        self.calories = calories
        self.description = description
        self.imageUrl = imageUrl
        self.crazyFunDescription = crazyFunDescription
        self.realRestaurantName = realRestaurantName
        self.restaurantAddress = restaurantAddress
        self.latitude = latitude
        self.longitude = longitude
        self.distanceInMeters = distanceInMeters
        self.mapItemIdentifier = mapItemIdentifier
    }

    public var wikipediaSearchQuery: String { title }

    public var restaurantName: String {
        if let real = realRestaurantName { return real }
        if let index = location.firstIndex(of: "(") {
            return String(location[..<index]).trimmingCharacters(in: .whitespaces)
        }
        return location
    }

    public var formattedDistance: String? {
        guard let meters = distanceInMeters else { return nil }
        if meters < 1000 { return String(format: "%.0f m", meters) }
        return String(format: "%.1f km", meters / 1000)
    }
}
