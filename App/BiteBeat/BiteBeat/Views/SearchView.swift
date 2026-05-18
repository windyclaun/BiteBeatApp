//
//  SearchView.swift
//  BiteBeat
//

import BiteBeatMusic
import MusicKit
import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    @State private var albums: MusicItemCollection<Album>?
    @State private var songs: MusicItemCollection<Song>?
    @State private var playlists: MusicItemCollection<Playlist>?
    @State private var isSearching = false
    @State private var errorMessage: String?

    var body: some View {
        List {
            if isSearching {
                Section {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }

            if let albums, !albums.isEmpty {
                Section("Albums") {
                    ForEach(albums, id: \.id) { album in
                        NavigationLink(value: album) {
                            AlbumRow(album: album)
                        }
                    }
                }
            }

            if let songs, !songs.isEmpty {
                Section("Songs") {
                    ForEach(songs, id: \.id) { song in
                        SongRow(song: song)
                    }
                }
            }

            if let playlists, !playlists.isEmpty {
                Section("Playlists") {
                    ForEach(playlists, id: \.id) { playlist in
                        NavigationLink(value: playlist) {
                            PlaylistRow(playlist: playlist)
                        }
                    }
                }
            }

            if !isSearching,
               searchText.count >= 2,
               albums?.isEmpty != false,
               songs?.isEmpty != false,
               playlists?.isEmpty != false
            {
                ContentUnavailableView.search(text: searchText)
            }
        }
        .navigationTitle("Search")
        .searchable(text: $searchText, prompt: "Albums, songs, playlists")
        .onSubmit(of: .search) { performSearch() }
        .onChange(of: searchText) { _, newValue in
            if newValue.isEmpty {
                albums = nil
                songs = nil
                playlists = nil
                errorMessage = nil
            }
        }
        .navigationDestination(for: Album.self) { album in
            AlbumDetailView(album: album)
        }
        .navigationDestination(for: Playlist.self) { playlist in
            PlaylistDetailView(playlist: playlist)
        }
        .alert("Search Error", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK") {}
        } message: {
            if let errorMessage { Text(errorMessage) }
        }
    }

    private func performSearch() {
        let term = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard term.count >= 2 else { return }

        isSearching = true
        Task {
            do {
                var request = MusicCatalogSearchRequest(term: term, types: [Album.self, Song.self, Playlist.self])
                request.limit = 15
                let response = try await request.response()
                albums = response.albums
                songs = response.songs
                playlists = response.playlists
            } catch {
                errorMessage = error.localizedDescription
            }
            isSearching = false
        }
    }
}

