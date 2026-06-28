import CoreLocation
import MapKit

struct NearbyFoodService {
    private let searchRadiusMeters: CLLocationDistance = 2000
    private let maxResults = 20

    func searchNearby(near location: CLLocation) async throws -> [FoodPlace] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "restaurant"
        request.resultTypes = .pointOfInterest
        request.pointOfInterestFilter = MKPointOfInterestFilter(
            including: [.restaurant, .cafe, .bakery, .foodMarket]
        )
        request.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: searchRadiusMeters * 2,
            longitudinalMeters: searchRadiusMeters * 2
        )

        let response = try await MKLocalSearch(request: request).start()

        let places: [FoodPlace] = response.mapItems.compactMap { item in
            guard let itemLocation = item.placemark.location else { return nil }
            let distance = itemLocation.distance(from: location)
            guard distance <= searchRadiusMeters else { return nil }

            let category = distance <= FoodPlaceCategory.nearbyThresholdMeters
                ? FoodPlaceCategory.nearby.rawValue
                : FoodPlaceCategory.others.rawValue

            return FoodPlace(
                name: item.name ?? "Unknown Place",
                address: item.placemark.title ?? "",
                latitude: itemLocation.coordinate.latitude,
                longitude: itemLocation.coordinate.longitude,
                distanceMeters: distance,
                category: category,
                phoneNumber: item.phoneNumber,
                websiteURL: item.url?.absoluteString
            )
        }

        return Array(places.sorted { $0.distanceMeters < $1.distanceMeters }.prefix(maxResults))
    }
}
