//
//  BiteBeatApp.swift
//  BiteBeat
//
//  Created by Muhammad Hisyam Kamil on 18/05/26.
//

import BiteBeatMusic
import SwiftData
import SwiftUI

@main
struct BiteBeatApp: App {
    @State private var musicSession = MusicSessionManager()
    @State private var locationService = LocationService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(musicSession)
                .environment(locationService)
                .preferredColorScheme(.light)
                .task {
                    await musicSession.observeSubscriptionUpdates()
                }
        }
        .modelContainer(for: [FoodPlace.self, MealRecord.self])
    }
}
