//
//  PlaylistDetailView.swift
//  BiteBeat
//

import BiteBeatMusic
import MusicKit
import SwiftUI

struct PlaylistDetailView: View {
    @Environment(MusicSessionManager.self) private var musicSession

    let playlist: Playlist

    @State private var detailedPlaylist: Playlist?
    @State private var entries: MusicItemCollection<Playlist.Entry>?
    @State private var isLoading = true
    @State private var playbackError: String?

    private var displayPlaylist: Playlist {
        detailedPlaylist ?? playlist
    }

    var body: some View {
        List {
            headerSection

            if isLoading {
                Section {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            } else if let entries, !entries.isEmpty {
                Section("Tracks") {
                    ForEach(entries, id: \.id) { entry in
                        PlaylistEntryRow(entry: entry) {
                            playEntry(entry)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(displayPlaylist.name)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Playback Error", isPresented: .constant(playbackError != nil)) {
            Button("OK") { playbackError = nil }
        } message: {
            if let playbackError { Text(playbackError) }
        }
        .task { await loadPlaylistDetails() }
    }

    @ViewBuilder
    private var headerSection: some View {
        Section {
            VStack(spacing: 16) {
                ArtworkImage(artwork: displayPlaylist.artwork, size: 200)
                    .shadow(color: .black.opacity(0.2), radius: 12, y: 6)

                if !displayPlaylist.description.isEmpty {
                    Text(displayPlaylist.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: 12) {
                    Button {
                        playPlaylist()
                    } label: {
                        Label("Play", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.pink)
                    .disabled(!musicSession.canPlayCatalogContent || isLoading)

                    if !musicSession.canPlayCatalogContent && musicSession.canBecomeSubscriber {
                        SubscriptionOfferButton(itemID: displayPlaylist.id)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
    }

    private func loadPlaylistDetails() async {
        isLoading = true
        do {
            let loaded = try await playlist.with([.entries])
            detailedPlaylist = loaded
            entries = loaded.entries
        } catch {
            playbackError = error.localizedDescription
        }
        isLoading = false
    }

    private func playPlaylist() {
        guard let detailedPlaylist else { return }
        Task {
            do {
                try await MusicPlaybackService.play(playlist: detailedPlaylist)
            } catch {
                playbackError = error.localizedDescription
            }
        }
    }

    private func playEntry(_ entry: Playlist.Entry) {
        guard let detailedPlaylist else { return }
        Task {
            do {
                try await MusicPlaybackService.play(playlist: detailedPlaylist, startingAt: entry)
            } catch {
                playbackError = error.localizedDescription
            }
        }
    }
}

private struct PlaylistEntryRow: View {
    let entry: Playlist.Entry
    let onPlay: () -> Void

    var body: some View {
        Button(action: onPlay) {
            HStack(spacing: 12) {
                ArtworkImage(artwork: entry.artwork, size: 44)
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.title)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    if !entry.artistName.isEmpty {
                        Text(entry.artistName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                Spacer()
                Image(systemName: "play.circle")
                    .foregroundStyle(.pink)
            }
        }
        .buttonStyle(.plain)
    }
}
