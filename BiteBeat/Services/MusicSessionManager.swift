//
//  MusicSessionManager.swift
//  test_music_kit
//

import MusicKit
import Observation

@MainActor
@Observable
final class MusicSessionManager {
    var authorizationStatus: MusicAuthorization.Status = .notDetermined
    var musicSubscription: MusicSubscription?

    var isAuthorized: Bool {
        authorizationStatus == .authorized
    }

    var canPlayCatalogContent: Bool {
        musicSubscription?.canPlayCatalogContent ?? false
    }

    var canBecomeSubscriber: Bool {
        musicSubscription?.canBecomeSubscriber ?? false
    }

    init() {
        authorizationStatus = MusicAuthorization.currentStatus
    }

    func refreshAuthorizationStatus() {
        authorizationStatus = MusicAuthorization.currentStatus
    }

    func refreshSubscription() async {
        musicSubscription = try? await MusicSubscription.current
    }

    func requestAuthorization() async {
        let status = await MusicAuthorization.request()
        authorizationStatus = status
    }

    func observeSubscriptionUpdates() async {
        await refreshSubscription()
        for await subscription in MusicSubscription.subscriptionUpdates {
            musicSubscription = subscription
        }
    }
}
