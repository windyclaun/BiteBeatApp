import SwiftUI
import Observation
import OSLog
import BiteBeatMusic

@Observable
@MainActor
public final class HomeViewModel {
    private let logger = Logger(subsystem: "com.pucakgunung.BiteBeat", category: "HomeViewModel")

    public static let defaultPlaylist: [BiteMusicTrack] = [
        BiteMusicTrack(id: "1484503472", title: "Cruel Summer", artistName: "Taylor Swift", genreNames: ["Pop"], artworkURL: nil),
        BiteMusicTrack(id: "1615577661", title: "As It Was", artistName: "Harry Styles", genreNames: ["Pop"], artworkURL: nil),
        BiteMusicTrack(id: "1499378199", title: "Blinding Lights", artistName: "The Weeknd", genreNames: ["R&B/Soul"], artworkURL: nil),
        BiteMusicTrack(id: "1192809232", title: "Shape of You", artistName: "Ed Sheeran", genreNames: ["Pop"], artworkURL: nil),
        BiteMusicTrack(id: "1529124425", title: "Dynamite", artistName: "K-Pop", genreNames: ["Pop"], artworkURL: nil)
    ]

    public var isExpanded = false
    public var recentSongs: [BiteMusicTrack] = []
    public var showConnectAlert = false
    public var isRefreshing = false
    public var selectedMealToday: Meal?

    public init() {
        refreshSelectedMealToday()
    }

    public var canAnalyzeToday: Bool {
        selectedMealToday == nil
    }

    public func refreshSelectedMealToday() {
        selectedMealToday = DailyMealSelectionStore.selectedMealForToday()
    }

    public func fetchRecentSongs(using musicSession: MusicSessionManager) async {
        isRefreshing = true
        if musicSession.isAuthorized {
            do {
                let songs = try await musicSession.fetchRecentlyPlayed(limit: 10)
                if !songs.isEmpty {
                    recentSongs = songs
                } else {
                    recentSongs = await musicSession.fetchDefaultPlaylist()
                }
            } catch {
                if isPrivacyAcknowledgementNeeded(error) {
                    logger.debug("Music privacy acknowledgement pending; using sample playlist.")
                } else {
                    logger.error("Failed to fetch recent songs: \(error.localizedDescription)")
                }
                recentSongs = await musicSession.fetchDefaultPlaylist()
            }
        } else {
            recentSongs = await musicSession.fetchDefaultPlaylist()
        }
        isRefreshing = false
    }

    private func isPrivacyAcknowledgementNeeded(_ error: any Error) -> Bool {
        let nsError = error as NSError
        return nsError.domain == "ICError" && nsError.code == -7007
    }
}
