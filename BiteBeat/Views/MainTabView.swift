//
//  MainTabView.swift
//  test_music_kit
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Library", systemImage: "music.note.list") {
                NavigationStack {
                    LibraryPlaylistsView()
                }
            }

            Tab("Search", systemImage: "magnifyingglass") {
                NavigationStack {
                    SearchView()
                }
            }

            Tab("Genres", systemImage: "guitars") {
                NavigationStack {
                    GenresView()
                }
            }

            Tab("Account", systemImage: "person.crop.circle") {
                NavigationStack {
                    AccountView()
                }
            }
        }
        .tint(.pink)
    }
}
