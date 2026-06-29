import CoreLocation
import MapKit
import OSLog

public enum NearbyRestaurantFinder {
    private static let logger = Logger(subsystem: "com.pucakgunung.BiteBeat", category: "NearbyRestaurantFinder")

    public static func search(
        near location: CLLocation,
        radius: CLLocationDistance = 2000
    ) async throws -> [NearbyRestaurant] {
        var results = try await performSearch(near: location, radius: radius)

        if results.isEmpty {
            logger.info("No restaurants within \(radius)m, widening to 5km")
            results = try await performSearch(near: location, radius: 5000)
        }

        logger.info("Found \(results.count) restaurants")
        return results
    }

    private static func performSearch(
        near location: CLLocation,
        radius: CLLocationDistance
    ) async throws -> [NearbyRestaurant] {
        let request = MKLocalPointsOfInterestRequest(
            center: location.coordinate,
            radius: radius
        )
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.restaurant])

        let search = MKLocalSearch(request: request)
        let response = try await search.start()

        let restaurants: [NearbyRestaurant] = response.mapItems.compactMap { mapItem in
            guard let name = mapItem.name else { return nil }

            let itemLocation = mapItem.location
            let distance = itemLocation.distance(from: location)
            let addressString = mapItem.address?.fullAddress ?? ""

            return NearbyRestaurant(
                name: name,
                address: addressString,
                coordinate: itemLocation.coordinate,
                distanceInMeters: distance,
                mapItemIdentifier: mapItem.identifier?.rawValue
            )
        }

        return restaurants.sorted { $0.distanceInMeters < $1.distanceInMeters }
    }
}

public enum MapsHelper {
    private static let logger = Logger(subsystem: "com.pucakgunung.BiteBeat", category: "MapsHelper")

    public static func openInMaps(for meal: Meal) async {
        if let idString = meal.mapItemIdentifier,
           let identifier = MKMapItem.Identifier(rawValue: idString) {
            let request = MKMapItemRequest(mapItemIdentifier: identifier)
            do {
                let mapItem = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<MKMapItem, any Error>) in
                    request.getMapItem { item, error in
                        if let error {
                            continuation.resume(throwing: error)
                        } else if let item {
                            continuation.resume(returning: item)
                        } else {
                            continuation.resume(throwing: NSError(domain: "MapsHelper", code: -1))
                        }
                    }
                }
                mapItem.openInMaps(launchOptions: nil)
                return
            } catch {
                logger.info("Identifier re-fetch failed, falling back to coordinate: \(error.localizedDescription)")
            }
        }

        if let lat = meal.latitude, let long = meal.longitude {
            let location = CLLocation(latitude: lat, longitude: long)
            let address = meal.restaurantAddress ?? ""
            let mkAddress = MKAddress(fullAddress: address, shortAddress: nil)
            let mapItem = MKMapItem(location: location, address: mkAddress)
            mapItem.name = meal.realRestaurantName ?? meal.restaurantName
            mapItem.openInMaps(launchOptions: nil)
        }
    }
}
