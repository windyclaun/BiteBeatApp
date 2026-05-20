//
//  ProfileViewModel.swift
//  BiteBeat
//

import SwiftUI
import Observation
import BiteBeatMusic

@Observable
@MainActor
public final class ProfileViewModel {
    public var recentSongs: [BiteMusicTrack] = []
    public var dominantVibeName: String = "Loading..."
    public var dominantVibeDescription: String = "Loading..."
    public var isLoadingVibe = true
    public var storefrontCountry = "Loading…"
    
    private static let countries: [String: String] = [
        "id": "Indonesia 🇮🇩",
        "us": "United States 🇺🇸",
        "gb": "United Kingdom 🇬🇧",
        "sg": "Singapore 🇸🇬",
        "my": "Malaysia 🇲🇾",
        "jp": "Japan 🇯🇵",
        "au": "Australia 🇦🇺",
        "ca": "Canada 🇨🇦",
        "de": "Germany 🇩🇪",
        "fr": "France 🇫🇷"
    ]
    
    public init() {}
    
    public func fetchRecentSongsAndAnalyze(using musicSession: MusicSessionManager) async {
        isLoadingVibe = true
        
        let countryCode = await musicSession.fetchStorefrontCountryCode()
        
        if let code = countryCode {
            let cleanCode = code.lowercased()
            storefrontCountry = Self.countries[cleanCode] ?? cleanCode.uppercased()
        } else {
            storefrontCountry = "Not Available"
        }
        
        do {
            recentSongs = try await musicSession.fetchRecentlyPlayed(limit: 10)
            
            if recentSongs.isEmpty {
                recentSongs = []
            }
            
            if #available(iOS 26.0, *) {
                let analyzer = MusicToFoodAnalyzer()
                let result = try await analyzer.analyze(songs: recentSongs)
                dominantVibeName = result.vibeName
                dominantVibeDescription = result.vibeDescription
            } else {
                dominantVibeName = "Classic Mix"
                dominantVibeDescription = "Apple Intelligence requires iOS 26.0 or newer."
            }
        } catch {
            dominantVibeName = "Classic Mix"
            dominantVibeDescription = "Failed to load Apple Intelligence insights: \(error.localizedDescription)"
        }
        
        isLoadingVibe = false
    }
    
    public func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
}
