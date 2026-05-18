//
//  SubscriptionOfferButton.swift
//  BiteBeat
//

import BiteBeatMusic
import MusicKit
import SwiftUI

struct SubscriptionOfferButton: View {
    @Environment(MusicSessionManager.self) private var musicSession
    let itemID: MusicItemID
    @State private var isShowingOffer = false

    var body: some View {
        Button {
            isShowingOffer = true
        } label: {
            Label("Join Apple Music", systemImage: "apple.logo")
                .font(.subheadline.weight(.semibold))
        }
        .buttonStyle(.borderedProminent)
        .tint(.pink)
        .disabled(!musicSession.canBecomeSubscriber)
        .musicSubscriptionOffer(isPresented: $isShowingOffer, options: offerOptions)
    }

    private var offerOptions: MusicSubscriptionOffer.Options {
        var options = MusicSubscriptionOffer.Options()
        options.itemID = itemID
        return options
    }
}
