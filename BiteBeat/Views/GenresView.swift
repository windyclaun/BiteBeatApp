//
//  GenresView.swift
//  test_music_kit
//

import MusicKit
import SwiftUI

private struct GenresResponse: Decodable {
    let data: [Genre]
}

struct GenresView: View {
    @State private var genres: [Genre] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if isLoading && genres.isEmpty {
                ProgressView("Loading genres…")
            } else if let errorMessage, genres.isEmpty {
                ContentUnavailableView {
                    Label("Couldn't Load Genres", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(errorMessage)
                } actions: {
                    Button("Try Again", action: loadGenres)
                }
            } else {
                List(genres, id: \.id) { genre in
                    HStack(spacing: 14) {
                        Image(systemName: "guitars.fill")
                            .font(.title2)
                            .foregroundStyle(.pink.gradient)
                            .frame(width: 44)
                        Text(genre.name)
                            .font(.body.weight(.medium))
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Genres")
        .refreshable { await loadGenresAsync() }
        .task { await loadGenresAsync() }
    }

    private func loadGenres() {
        Task { await loadGenresAsync() }
    }

    private func loadGenresAsync() async {
        isLoading = true
        errorMessage = nil
        do {
            let countryCode = try await MusicDataRequest.currentCountryCode
            let url = URL(string: "https://api.music.apple.com/v1/catalog/\(countryCode)/genres")!
            let dataRequest = MusicDataRequest(urlRequest: URLRequest(url: url))
            let dataResponse = try await dataRequest.response()
            let genresResponse = try JSONDecoder().decode(GenresResponse.self, from: dataResponse.data)
            genres = genresResponse.data
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
