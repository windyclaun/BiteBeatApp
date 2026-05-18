//
//  BiteBeatApp.swift
//  BiteBeat
//

import SwiftUI

@main
struct BiteBeatApp: App {
    @State private var musicSession = MusicSessionManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(musicSession)
                .task {
                    await musicSession.observeSubscriptionUpdates()
                }
        }
    }
}
