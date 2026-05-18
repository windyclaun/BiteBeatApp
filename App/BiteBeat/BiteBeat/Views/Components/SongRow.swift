//
//  SongRow.swift
//  BiteBeat
//

import BiteBeatMusic
import MusicKit
import SwiftUI

struct SongRow: View {
    @Environment(MusicSessionManager.self) private var musicSession

    let song: Song
    @State private var playbackError: String?

    var body: some View {
        Button {
            playSong()
        } label: {
            HStack(spacing: 14) {
                ArtworkImage(artwork: song.artwork)
                VStack(alignment: .leading, spacing: 4) {
                    Text(song.title)
                        .font(.body.weight(.medium))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Text(song.artistName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                Spacer()
                Image(systemName: "play.circle")
                    .foregroundStyle(.pink)
            }
        }
        .buttonStyle(.plain)
        .disabled(!musicSession.canPlayCatalogContent)
        .alert("Playback Error", isPresented: Binding(
            get: { playbackError != nil },
            set: { if !$0 { playbackError = nil } }
        )) {
            Button("OK") {}
        } message: {
            if let playbackError { Text(playbackError) }
        }
    }

    private func playSong() {
        Task {
            do {
                try await MusicPlaybackService.play(song: song)
            } catch {
                playbackError = error.localizedDescription
            }
        }
    }
}
