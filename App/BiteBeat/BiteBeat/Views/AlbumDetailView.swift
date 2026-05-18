//
//  AlbumDetailView.swift
//  BiteBeat
//

import BiteBeatMusic
import MusicKit
import SwiftUI

struct AlbumDetailView: View {
    @Environment(MusicSessionManager.self) private var musicSession

    let album: Album

    @State private var detailedAlbum: Album?
    @State private var tracks: MusicItemCollection<Track>?
    @State private var relatedAlbums: MusicItemCollection<Album>?
    @State private var relatedAlbumsTitle: String?
    @State private var isLoading = true
    @State private var playbackError: String?

    private var displayAlbum: Album {
        detailedAlbum ?? album
    }

    var body: some View {
        List {
            headerSection

            if isLoading {
                Section {
                    HStack {
                        Spacer()
                        ProgressView("Loading album…")
                        Spacer()
                    }
                }
            }

            if let tracks, !tracks.isEmpty {
                Section("Tracks") {
                    ForEach(tracks, id: \.id) { track in
                        TrackRow(track: track) {
                            playTrack(track)
                        }
                    }
                }
            }

            if let relatedAlbums, !relatedAlbums.isEmpty {
                Section(relatedAlbumsTitle ?? "Related Albums") {
                    ForEach(relatedAlbums.prefix(6), id: \.id) { related in
                        NavigationLink(value: related) {
                            AlbumRow(album: related)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(displayAlbum.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Album.self) { related in
            AlbumDetailView(album: related)
        }
        .alert("Playback Error", isPresented: .constant(playbackError != nil)) {
            Button("OK") { playbackError = nil }
        } message: {
            if let playbackError { Text(playbackError) }
        }
        .task { await loadAlbumDetails() }
    }

    @ViewBuilder
    private var headerSection: some View {
        Section {
            VStack(spacing: 16) {
                ArtworkImage(artwork: displayAlbum.artwork, size: 220)
                    .shadow(color: .black.opacity(0.25), radius: 16, y: 8)

                VStack(spacing: 6) {
                    Text(displayAlbum.title)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                    Text(displayAlbum.artistName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if let releaseDate = displayAlbum.releaseDate {
                        Text(releaseDate.formatted(.dateTime.year().month()))
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }

                HStack(spacing: 12) {
                    Button {
                        playAlbum()
                    } label: {
                        Label("Play", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.pink)
                    .disabled(!musicSession.canPlayCatalogContent || isLoading)

                    if !musicSession.canPlayCatalogContent && musicSession.canBecomeSubscriber {
                        SubscriptionOfferButton(itemID: displayAlbum.id)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
    }

    private func loadAlbumDetails() async {
        isLoading = true
        do {
            let loaded = try await album.with([.artists, .tracks, .relatedAlbums])
            detailedAlbum = loaded
            tracks = loaded.tracks
            if let related = loaded.relatedAlbums {
                relatedAlbums = related
                relatedAlbumsTitle = related.title
            }
        } catch {
            playbackError = error.localizedDescription
        }
        isLoading = false
    }

    private func playAlbum() {
        guard let detailedAlbum else { return }
        Task {
            do {
                try await MusicPlaybackService.play(album: detailedAlbum)
            } catch {
                playbackError = error.localizedDescription
            }
        }
    }

    private func playTrack(_ track: Track) {
        guard let detailedAlbum else { return }
        Task {
            do {
                try await MusicPlaybackService.play(album: detailedAlbum, startingAt: track)
            } catch {
                playbackError = error.localizedDescription
            }
        }
    }
}

private struct TrackRow: View {
    let track: Track
    let onPlay: () -> Void

    var body: some View {
        Button(action: onPlay) {
            HStack {
                Text("\(track.trackNumber ?? 0)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .frame(width: 24, alignment: .trailing)
                VStack(alignment: .leading, spacing: 2) {
                    Text(track.title)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    if track.artistName != track.title {
                        Text(track.artistName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                Spacer()
                if let duration = track.duration {
                    Text(formatDuration(duration))
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                Image(systemName: "play.circle")
                    .foregroundStyle(.pink)
            }
        }
        .buttonStyle(.plain)
    }
}

private func formatDuration(_ seconds: TimeInterval) -> String {
    let total = Int(seconds)
    let minutes = total / 60
    let secs = total % 60
    return String(format: "%d:%02d", minutes, secs)
}

private struct AlbumRow: View {
    let album: Album

    var body: some View {
        HStack(spacing: 14) {
            ArtworkImage(artwork: album.artwork)
            VStack(alignment: .leading, spacing: 4) {
                Text(album.title)
                    .font(.body.weight(.medium))
                    .lineLimit(1)
                Text(album.artistName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}
