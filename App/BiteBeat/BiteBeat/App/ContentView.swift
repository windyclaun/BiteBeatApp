//
//  ContentView.swift
//  BiteBeat
//
//  Created by Muhammad Hisyam Kamil on 18/05/26.
//

import BiteBeatMusic
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
