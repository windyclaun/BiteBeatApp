import Foundation
import SwiftData

@Model
final class FoodPlace {
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    var distanceMeters: Double
    var category: String
    var phoneNumber: String?
    var websiteURL: String?
    var fetchedAt: Date

    init(
        name: String,
        address: String,
        latitude: Double,
        longitude: Double,
        distanceMeters: Double,
        category: String,
        phoneNumber: String? = nil,
        websiteURL: String? = nil,
        fetchedAt: Date = Date()
    ) {
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.distanceMeters = distanceMeters
        self.category = category
        self.phoneNumber = phoneNumber
        self.websiteURL = websiteURL
        self.fetchedAt = fetchedAt
    }
}

enum FoodPlaceCategory: String {
    case nearby
    case others

    static let nearbyThresholdMeters: Double = 500
}

extension FoodPlace {
    var info: FoodPlaceInfo {
        FoodPlaceInfo(
            name: name,
            address: address,
            distance: Self.formatDistance(distanceMeters),
            category: category
        )
    }

    static func formatDistance(_ meters: Double) -> String {
        if meters < 1000 {
            return "\(Int(meters.rounded())) m"
        }
        return String(format: "%.1f km", meters / 1000)
    }
}
