import CoreLocation
import OSLog

@Observable
@MainActor
public final class LocationManager: NSObject {
    public var authorizationStatus: CLAuthorizationStatus = .notDetermined

    @ObservationIgnored private let manager = CLLocationManager()
    @ObservationIgnored private var locationContinuation: CheckedContinuation<CLLocation, any Error>?
    @ObservationIgnored private var locationRequestID = UUID()
    @ObservationIgnored private var authContinuation: CheckedContinuation<Void, any Error>?
    @ObservationIgnored private var authRequestID = UUID()
    @ObservationIgnored private let logger = Logger(subsystem: "com.pucakgunung.BiteBeat", category: "LocationManager")

    public enum LocationError: Error {
        case timeout
        case unauthorized
        case failed
    }

    public var isAuthorized: Bool {
        authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    }

    public override init() {
        super.init()
        manager.delegate = self
        authorizationStatus = manager.authorizationStatus
    }

    public func refreshAuthorizationStatus() {
        authorizationStatus = manager.authorizationStatus
    }

    /// Just-in-time: requests WhenInUse access (if needed), then one-shot location.
    public func requestAccessAndLocate(timeout: TimeInterval = 10) async -> CLLocation? {
        if authorizationStatus == .notDetermined {
            do {
                try await requestAuthorization()
            } catch {
                logger.error("Authorization request failed: \(error.localizedDescription)")
                return nil
            }
        }

        guard isAuthorized else { return nil }

        do {
            return try await fetchLocation(timeout: timeout)
        } catch {
            logger.error("Location fetch failed: \(error.localizedDescription)")
            return nil
        }
    }

    private func requestAuthorization(timeout: TimeInterval = 8) async throws {
        manager.requestWhenInUseAuthorization()
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
            let requestID = UUID()
            authRequestID = requestID
            authContinuation = continuation

            Task { [weak self] in
                try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                guard let self else { return }
                guard self.authRequestID == requestID else { return }
                if let cont = self.authContinuation {
                    self.authContinuation = nil
                    cont.resume()
                }
            }
        }
    }

    private func fetchLocation(timeout: TimeInterval) async throws -> CLLocation {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<CLLocation, any Error>) in
            let requestID = UUID()
            locationRequestID = requestID
            locationContinuation = continuation
            manager.requestLocation()

            Task { [weak self] in
                try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                guard let self else { return }
                guard self.locationRequestID == requestID else { return }
                if let cont = self.locationContinuation {
                    self.locationContinuation = nil
                    cont.resume(throwing: LocationError.timeout)
                }
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus
            if let cont = authContinuation {
                authContinuation = nil
                cont.resume()
            }
        }
    }

    nonisolated public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            if let location = locations.last, let cont = locationContinuation {
                locationContinuation = nil
                cont.resume(returning: location)
            }
        }
    }

    nonisolated public func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        Task { @MainActor in
            logger.error("CLLocationManager didFail: \(error.localizedDescription)")
            if let cont = locationContinuation {
                locationContinuation = nil
                cont.resume(throwing: LocationError.failed)
            }
        }
    }
}
