//
//  MusicPlaybackService.swift
//  test_music_kit
//

import MusicKit

enum MusicPlaybackService {
    private static let player = ApplicationMusicPlayer.shared

    static func play(album: Album, startingAt track: Track? = nil) async throws {
        let loaded = try await album.with([.tracks])
        guard let tracks = loaded.tracks, !tracks.isEmpty else { return }
        let startTrack = track ?? tracks[tracks.startIndex]
        player.queue = ApplicationMusicPlayer.Queue(album: loaded, startingAt: startTrack)
        try await player.play()
    }

    static func play(playlist: Playlist, startingAt entry: Playlist.Entry? = nil) async throws {
        let loaded = try await playlist.with([.entries])
        guard let entries = loaded.entries, !entries.isEmpty else { return }
        let startEntry = entry ?? entries[entries.startIndex]
        player.queue = ApplicationMusicPlayer.Queue(playlist: loaded, startingAt: startEntry)
        try await player.play()
    }

    static func play(song: Song) async throws {
        player.queue = ApplicationMusicPlayer.Queue(for: [song])
        try await player.play()
    }
}
