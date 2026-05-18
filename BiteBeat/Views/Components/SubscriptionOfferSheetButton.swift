//
//  SubscriptionOfferSheetButton.swift
//  test_music_kit
//

import MusicKit
import SwiftUI

struct SubscriptionOfferSheetButton: View {
    @Environment(MusicSessionManager.self) private var musicSession
    @State private var isShowingOffer = false

    var body: some View {
        Button {
            isShowingOffer = true
        } label: {
            Label("Join Apple Music", systemImage: "apple.logo")
        }
        .disabled(!musicSession.canBecomeSubscriber)
        .musicSubscriptionOffer(isPresented: $isShowingOffer)
    }
}
