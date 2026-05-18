//
//  AccountView.swift
//  BiteBeat
//

import BiteBeatMusic
import MusicKit
import SwiftUI

struct AccountView: View {
    @Environment(MusicSessionManager.self) private var musicSession

    var body: some View {
        List {
            Section("Apple Music") {
                LabeledContent("Authorization") {
                    Text(statusLabel)
                        .foregroundStyle(statusColor)
                }

                if let subscription = musicSession.musicSubscription {
                    LabeledContent("Play Catalog") {
                        Image(systemName: subscription.canPlayCatalogContent ? "checkmark.circle.fill" : "xmark.circle")
                            .foregroundStyle(subscription.canPlayCatalogContent ? .green : .secondary)
                    }
                    LabeledContent("iCloud Music Library") {
                        Image(systemName: subscription.hasCloudLibraryEnabled ? "checkmark.circle.fill" : "xmark.circle")
                            .foregroundStyle(subscription.hasCloudLibraryEnabled ? .green : .secondary)
                    }
                    LabeledContent("Can Subscribe") {
                        Image(systemName: subscription.canBecomeSubscriber ? "checkmark.circle.fill" : "xmark.circle")
                            .foregroundStyle(subscription.canBecomeSubscriber ? .green : .secondary)
                    }
                }
            }

            Section {
                SubscriptionOfferSheetButton()

                Button("Refresh Status", systemImage: "arrow.clockwise") {
                    musicSession.refreshAuthorizationStatus()
                    Task { await musicSession.refreshSubscription() }
                }
            }

            Section(footer: Text("Apple Music authorization is managed securely by iOS. To fully revoke access, disable 'Media & Apple Music' in the system settings for BiteBeat.")) {
                Button(role: .destructive) {
                    openSystemSettings()
                } label: {
                    Label("Disconnect Apple Music", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }

            Section {
                Text("Enable MusicKit for your App ID in the Apple Developer portal (App Services → MusicKit) so developer tokens are generated automatically.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Account")
    }

    private var statusLabel: String {
        switch musicSession.authorizationStatus {
        case .authorized: "Authorized"
        case .denied: "Denied"
        case .restricted: "Restricted"
        case .notDetermined: "Not Determined"
        @unknown default: "Unknown"
        }
    }

    private var statusColor: Color {
        switch musicSession.authorizationStatus {
        case .authorized: .green
        case .denied, .restricted: .orange
        default: .secondary
        }
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
}
