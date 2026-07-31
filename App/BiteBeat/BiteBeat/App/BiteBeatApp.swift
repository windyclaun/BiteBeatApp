//
//  BiteBeatApp.swift
//  BiteBeat
//
//  Created by Muhammad Hisyam Kamil on 18/05/26.
//

import BiteBeatMusic
import SwiftUI

@main
struct BiteBeatApp: App {
    @State private var musicSession = MusicSessionManager()
    @State private var locationManager = LocationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(musicSession)
                .environment(locationManager)
                .task {
                    await musicSession.observeSubscriptionUpdates()
                }
        }
    }
}
