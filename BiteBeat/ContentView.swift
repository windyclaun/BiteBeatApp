//
//  ContentView.swift
//  test_music_kit
//

import SwiftUI

struct ContentView: View {
    @Environment(MusicSessionManager.self) private var musicSession

    var body: some View {
        Group {
            if musicSession.isAuthorized {
                MainTabView()
            } else {
                AuthorizationView()
            }
        }
        .animation(.easeInOut, value: musicSession.isAuthorized)
        .onAppear {
            musicSession.refreshAuthorizationStatus()
        }
    }
}

#Preview {
    ContentView()
        .environment(MusicSessionManager())
}
