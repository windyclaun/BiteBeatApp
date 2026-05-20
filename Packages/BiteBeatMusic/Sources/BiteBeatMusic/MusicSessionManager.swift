//
//  MusicSessionManager.swift
//  BiteBeatMusic
//

import MusicKit
import Observation
import StoreKit

public struct BiteMusicTrack: Identifiable, Sendable, Codable {
    public let id: String
    public let title: String
    public let artistName: String
    public let genreNames: [String]
    public let artworkURL: URL?

    public init(id: String, title: String, artistName: String, genreNames: [String], artworkURL: URL?) {
        self.id = id
        self.title = title
        self.artistName = artistName
        self.genreNames = genreNames
        self.artworkURL = artworkURL
    }
}

@MainActor
@Observable
public final class MusicSessionManager {
    public var authorizationStatus: MusicAuthorization.Status = .notDetermined
    public var musicSubscription: MusicSubscription?

    @ObservationIgnored
    private let storefrontController = SKCloudServiceController()

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
        musicSubscription = try? await MusicSubscription.current
    }

    public func requestAuthorization() async {
        let status = await MusicAuthorization.request()
        authorizationStatus = status
    }

    public func observeSubscriptionUpdates() async {
        await refreshSubscription()
        for await subscription in MusicSubscription.subscriptionUpdates {
            musicSubscription = subscription
        }
    }

    public func fetchRecentlyPlayed(limit: Int = 10) async throws -> [BiteMusicTrack] {
        var request = MusicRecentlyPlayedRequest<Song>()
        request.limit = limit
        let response = try await request.response()
        return response.items.map { song in
            let url = song.artwork?.url(width: 300, height: 300)
            return BiteMusicTrack(
                id: song.id.rawValue,
                title: song.title,
                artistName: song.artistName,
                genreNames: song.genreNames,
                artworkURL: url
            )
        }
    }

    public func fetchStorefrontCountryCode() async -> String? {
        if #available(iOS 18.0, *) {
            return try? await MusicDataRequest.currentCountryCode
        } else {
            return try? await storefrontController.requestStorefrontCountryCode()
        }
    }
}

