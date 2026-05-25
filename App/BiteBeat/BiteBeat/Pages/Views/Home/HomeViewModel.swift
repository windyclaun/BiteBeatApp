//
//  HomeViewModel.swift
//  BiteBeat
//

import SwiftUI
import Observation
import BiteBeatMusic

@Observable
@MainActor
public final class HomeViewModel {
public static let defaultPlaylist: [BiteMusicTrack] = [
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

    public var isExpanded = false
    public var navigateToLoading = false
    public var recentSongs: [BiteMusicTrack] = []
    public var showConnectAlert = false
    public var isRefreshing = false
    
    // Calculated food recommendations and navigation
    public var navigateToRecommendation = false
    public var navigateToSavedMeal = false
    public var calculatedVibeName: String?
    public var calculatedMain: Meal?
    public var calculatedAlternatives: [Meal] = []
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
                print("Failed to fetch recent songs: \(error)")
                recentSongs = await musicSession.fetchDefaultPlaylist()
            }
        } else {
            recentSongs = await musicSession.fetchDefaultPlaylist()
        }
        isRefreshing = false
    }
    
    public func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }

}

