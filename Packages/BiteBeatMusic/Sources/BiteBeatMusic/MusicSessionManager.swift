//
//  MusicSessionManager.swift
//  BiteBeatMusic
//

import MusicKit
import Observation

@MainActor
@Observable
public final class MusicSessionManager {
    public var authorizationStatus: MusicAuthorization.Status = .notDetermined
    public var musicSubscription: MusicSubscription?

    public var isAuthorized: Bool {
        authorizationStatus == .authorized
    }

    public var canPlayCatalogContent: Bool {
        musicSubscription?.canPlayCatalogContent ?? false
    }

    public var canBecomeSubscriber: Bool {
        musicSubscription?.canBecomeSubscriber ?? false
    }

    public init() {
        authorizationStatus = MusicAuthorization.currentStatus
    }

    public func refreshAuthorizationStatus() {
        authorizationStatus = MusicAuthorization.currentStatus
    }

    public func refreshSubscription() async {
        #if !targetEnvironment(simulator)
        musicSubscription = try? await MusicSubscription.current
        #else
        musicSubscription = nil
        #endif
    }

    public func requestAuthorization() async {
        let status = await MusicAuthorization.request()
        authorizationStatus = status
    }

    public func observeSubscriptionUpdates() async {
        #if !targetEnvironment(simulator)
        await refreshSubscription()
        for await subscription in MusicSubscription.subscriptionUpdates {
            musicSubscription = subscription
        }
        #endif
    }
}
