import BiteBeatMusic
import MusicKit
import SwiftUI

struct AuthorizationView: View {
    @Environment(MusicSessionManager.self) private var musicSession
    @State private var isRequesting = false

    var body: some View {
        VStack(spacing: 28) {
            Image(systemName: "music.note.house.fill")
                .font(.system(size: 72))
                .foregroundStyle(.pink.gradient)
                .symbolRenderingMode(.hierarchical)

            VStack(spacing: 10) {
                Text("Apple Music")
                    .font(.largeTitle.bold())

                Text("Connect your Apple Music account to translate your recently played beats into personalized meal recommendations.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            if musicSession.authorizationStatus == .denied
                || musicSession.authorizationStatus == .restricted
            {
                statusBanner
            }

            Button {
                requestAccess()
            } label: {
                Group {
                    if isRequesting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Label("Connect Apple Music", systemImage: "apple.logo")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(.pink)
            .disabled(isRequesting)
            .padding(.horizontal, 32)
        }
        .padding()
        .onAppear {
            musicSession.refreshAuthorizationStatus()
        }
    }

    @ViewBuilder
    private var statusBanner: some View {
        let message: String = switch musicSession.authorizationStatus {
        case .denied:
            "Access was denied. Open Settings → Privacy & Security → Media & Apple Music to allow access."
        case .restricted:
            "Apple Music access is restricted on this device."
        default:
            ""
        }

        Label(message, systemImage: "exclamationmark.triangle.fill")
            .font(.footnote)
            .foregroundStyle(.orange)
            .padding()
            .background(.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
    }

    private func requestAccess() {
        isRequesting = true
        Task {
            await musicSession.requestAuthorization()
            isRequesting = false
        }
    }
}
