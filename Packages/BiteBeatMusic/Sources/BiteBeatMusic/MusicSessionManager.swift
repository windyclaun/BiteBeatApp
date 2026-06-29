//
//  MusicSessionManager.swift
//  BiteBeatMusic
//

import MusicKit
import Observation
import OSLog
import StoreKit

public enum BiteMusicAuthorizationStatus: Sendable, Codable, Equatable {
    case notDetermined
    case denied
    case restricted
    case authorized
}

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
    public var authorizationStatus: BiteMusicAuthorizationStatus = .notDetermined
    public var musicSubscription: MusicSubscription?

    @ObservationIgnored
    private let storefrontController = SKCloudServiceController()

    @ObservationIgnored
    private let logger = Logger(subsystem: "com.pucakgunung.BiteBeat", category: "MusicSessionManager")

    public var isAuthorized: Bool {
        authorizationStatus == .authorized
    }

    public var canPlayCatalogContent: Bool {
        musicSubscription?.canPlayCatalogContent ?? false
    }

    public var canBecomeSubscriber: Bool {
        musicSubscription?.canBecomeSubscriber ?? false
    }

    private func mapStatus(_ status: MusicAuthorization.Status) -> BiteMusicAuthorizationStatus {
        switch status {
        case .notDetermined: return .notDetermined
        case .denied: return .denied
        case .restricted: return .restricted
        case .authorized: return .authorized
        @unknown default: return .notDetermined
        }
    }

    public init() {
        authorizationStatus = mapStatus(MusicAuthorization.currentStatus)
    }

    public func refreshAuthorizationStatus() {
        authorizationStatus = mapStatus(MusicAuthorization.currentStatus)
    }

    public func refreshSubscription() async {
        musicSubscription = try? await MusicSubscription.current
    }

    public func requestAuthorization() async {
        let status = await MusicAuthorization.request()
        authorizationStatus = mapStatus(status)
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

    public func fetchTracksByIDs(_ ids: [String]) async throws -> [BiteMusicTrack] {
        let musicItemIDs = ids.map { MusicItemID($0) }
        var request = MusicCatalogResourceRequest<Song>(matching: \.id, memberOf: musicItemIDs)
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

    public func playRandomTrack(from tracks: [BiteMusicTrack]) async {
        guard authorizationStatus == .authorized else { return }

        if musicSubscription == nil {
            await refreshSubscription()
        }

        guard canPlayCatalogContent else { return }

        for track in tracks.shuffled() {
            do {
                guard let song = try await fetchPlayableSong(id: track.id) else { continue }
                let player = ApplicationMusicPlayer.shared
                player.queue = ApplicationMusicPlayer.Queue(for: [song], startingAt: song)
                try await player.play()
                return
            } catch {
                continue
            }
        }
    }

    public func pausePlayback() {
        ApplicationMusicPlayer.shared.pause()
    }

    private func fetchPlayableSong(id: String) async throws -> Song? {
        let musicItemID = MusicItemID(id)
        var request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: musicItemID)
        let response = try await request.response()
        return response.items.first
    }

    public func fetchDefaultPlaylist() async -> [BiteMusicTrack] {
        guard let url = Bundle.main.url(forResource: "default_playlist", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let urls = try? JSONDecoder().decode([String].self, from: data) else {
            return getMockDefaultPlaylist()
        }

        var trackIDs: [String] = []
        for urlString in urls {
            if let components = URLComponents(string: urlString),
               let trackId = components.queryItems?.first(where: { $0.name == "i" })?.value {
                trackIDs.append(trackId)
            }
        }

        if trackIDs.isEmpty {
            return getMockDefaultPlaylist()
        }

        guard isAuthorized, canPlayCatalogContent else {
            return getMockDefaultPlaylist()
        }
        
        do {
            let fetched = try await fetchTracksByIDs(trackIDs)
            if fetched.isEmpty {
                return getMockDefaultPlaylist()
            }
            return fetched
        } catch {
            logger.error("Failed to fetch default playlist from Apple Music API: \(error.localizedDescription)")
            return getMockDefaultPlaylist()
        }
    }

    public func getMockDefaultPlaylist() -> [BiteMusicTrack] {
        return [
            BiteMusicTrack(
                id: "1484503472",
                title: "Cruel Summer",
                artistName: "Taylor Swift",
                genreNames: ["Pop"],
                artworkURL: nil
            ),
            BiteMusicTrack(
                id: "1615577661",
                title: "As It Was",
                artistName: "Harry Styles",
                genreNames: ["Pop"],
                artworkURL: nil
            ),
            BiteMusicTrack(
                id: "1499378199",
                title: "Blinding Lights",
                artistName: "The Weeknd",
                genreNames: ["R&B/Soul"],
                artworkURL: nil
            ),
            BiteMusicTrack(
                id: "1192809232",
                title: "Shape of You",
                artistName: "Ed Sheeran",
                genreNames: ["Pop"],
                artworkURL: nil
            ),
            BiteMusicTrack(
                id: "1529124425",
                title: "Dynamite",
                artistName: "K-Pop",
                genreNames: ["Pop"],
                artworkURL: nil
            )
        ]
    }
}

