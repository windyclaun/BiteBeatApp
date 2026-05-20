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
    public var isExpanded = false
    public var navigateToLoading = false
    public var recentSongs: [BiteMusicTrack] = []
    public var showConnectAlert = false
    
    public init() {}
    
    public func fetchRecentSongs(using musicSession: MusicSessionManager) async {
        if musicSession.isAuthorized {
            do {
                recentSongs = try await musicSession.fetchRecentlyPlayed(limit: 10)
            } catch {
                print("Failed to fetch recent songs: \(error)")
                recentSongs = await musicSession.fetchDefaultPlaylist()
            }
        } else {
            recentSongs = await musicSession.fetchDefaultPlaylist()
        }
    }
    
    public func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }

}

