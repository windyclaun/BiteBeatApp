//
//  LibraryPlaylistsView.swift
//  test_music_kit
//

import MusicKit
import SwiftUI

struct LibraryPlaylistsView: View {
    @State private var playlists: [Playlist] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if isLoading && playlists.isEmpty {
                ProgressView("Loading playlists…")
            } else if let errorMessage, playlists.isEmpty {
                ContentUnavailableView {
                    Label("Couldn't Load Playlists", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(errorMessage)
                } actions: {
                    Button("Try Again", action: loadPlaylists)
                }
            } else if playlists.isEmpty {
                ContentUnavailableView(
                    "No Playlists",
                    systemImage: "music.note.list",
                    description: Text("Your Apple Music library playlists will appear here.")
                )
            } else {
                List(playlists, id: \.id) { playlist in
                    NavigationLink(value: playlist) {
                        PlaylistRow(playlist: playlist)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("My Playlists")
        .navigationDestination(for: Playlist.self) { playlist in
            PlaylistDetailView(playlist: playlist)
        }
        .refreshable { await loadPlaylistsAsync() }
        .task { await loadPlaylistsAsync() }
    }

    private func loadPlaylists() {
        Task { await loadPlaylistsAsync() }
    }

    private func loadPlaylistsAsync() async {
        isLoading = true
        errorMessage = nil
        do {
            var request = MusicLibraryRequest<Playlist>()
            request.sort(by: \.name, ascending: true)
            request.limit = 100
            let response = try await request.response()
            playlists = Array(response.items)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

private struct PlaylistRow: View {
    let playlist: Playlist

    var body: some View {
        HStack(spacing: 14) {
            ArtworkImage(artwork: playlist.artwork)
            VStack(alignment: .leading, spacing: 4) {
                Text(playlist.name)
                    .font(.body.weight(.medium))
                    .lineLimit(1)
                if let curatorName = playlist.curatorName {
                    Text(curatorName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
