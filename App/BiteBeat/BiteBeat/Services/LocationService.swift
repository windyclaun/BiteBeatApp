import CoreLocation
import Observation

enum LocationError: Error {
    case authorizationDenied
    case unavailable
}

@Observable
@MainActor
public final class LocationService: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    public private(set) var authorizationStatus: CLAuthorizationStatus

    public override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
    }

    public func requestWhenInUseAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    public func requestOneTimeLocation() async throws -> CLLocation {
        for try await update in CLLocationUpdate.liveUpdates() {
            if update.authorizationDenied || update.authorizationDeniedGlobally {
                throw LocationError.authorizationDenied
            }
            if let location = update.location {
                return location
            }
        }
        throw LocationError.unavailable
    }

    nonisolated public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = status
        }
    }
}
