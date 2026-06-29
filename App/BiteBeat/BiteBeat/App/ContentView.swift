import BiteBeatMusic
import FoundationModels
import SwiftUI

struct ContentView: View {
    @Environment(MusicSessionManager.self) private var musicSession
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasAcknowledgedAppleIntelligence") private var hasAcknowledgedAppleIntelligence = false

    var body: some View {
        Group {
            if !hasCompletedOnboarding && musicSession.authorizationStatus == .notDetermined {
                AuthorizationView()
                    .transition(.asymmetric(
                        insertion: .identity,
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
            } else if !hasAcknowledgedAppleIntelligence {
                AppleIntelligencePermissionView(hasAcknowledgedAppleIntelligence: $hasAcknowledgedAppleIntelligence)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
            } else {
                HomeView()
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.82), value: hasCompletedOnboarding)
        .animation(.spring(response: 0.6, dampingFraction: 0.82), value: hasAcknowledgedAppleIntelligence)
        .animation(.spring(response: 0.6, dampingFraction: 0.82), value: musicSession.authorizationStatus)
        .onAppear {
            musicSession.refreshAuthorizationStatus()
        }
    }
}

private struct AppleIntelligencePermissionView: View {
    @Binding var hasAcknowledgedAppleIntelligence: Bool
    private let model = SystemLanguageModel.default

    var body: some View {
        ZStack {
            Color.accentColor
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Spacer()

                Image("LogoApp")
                    .biteBeatFont(.displayLarge, weight: .bold)
                    .foregroundStyle(Color.onAccent)

                Text("BiteBeat")
                    .biteBeatFont(.displayMedium, weight: .bold)
                    .foregroundStyle(Color.onAccent)

                Spacer()
            }
            .blur(radius: 4)

            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "apple.intelligence")
                    .biteBeatFont(.title, weight: .semibold)
                    .foregroundStyle(Color.accentColor)

                Text("Apple Intelligence")
                    .biteBeatFont(.headline)
                    .foregroundStyle(.primary)

                Text("BiteBeat uses on-device Apple Intelligence to understand your music vibe and turn it into a food recommendation.")
                    .biteBeatFont(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                    .lineSpacing(2)

                statusBanner

                actionButtonsView
                    .padding(.top, 8)
            }
            .padding(24)
            .frame(maxWidth: 340)
            .glassEffect(.regular, in: .rect(cornerRadius: 20))
        }
    }

    private var statusBanner: some View {
        StatusLabel(
            icon: availabilityIcon,
            message: availabilityMessage,
            color: availabilityColor
        )
    }

    private var actionButtonsView: some View {
        VStack(spacing: 12) {
            if AppleIntelligenceHelper.isNotEnabled {
                Button {
                    SystemSettingsOpener.openAppleIntelligenceSettings()
                } label: {
                    Text("Open Settings")
                        .biteBeatFont(.subheadline, weight: .bold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.glassProminent)
                .tint(Color.accentColor)
            } else {
                Button {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.82)) {
                        hasAcknowledgedAppleIntelligence = true
                    }
                } label: {
                    Text("Continue")
                        .biteBeatFont(.subheadline, weight: .bold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.glassProminent)
                .tint(Color.accentColor)
            }
        }
    }

    private var availabilityMessage: String {
        switch model.availability {
        case .available:
            return "Apple Intelligence is ready on this device."
        case .unavailable(.appleIntelligenceNotEnabled):
            return "Apple Intelligence is turned off. Turn it on in Settings for AI-powered recommendations."
        case .unavailable(.modelNotReady):
            return "Apple Intelligence is still getting ready. You can continue and try again later."
        case .unavailable(.deviceNotEligible):
            return "This device does not support Apple Intelligence."
        case .unavailable:
            return "Apple Intelligence is not available right now."
        }
    }

    private var availabilityIcon: String {
        switch model.availability {
        case .available:
            return "checkmark.seal.fill"
        case .unavailable(.appleIntelligenceNotEnabled):
            return "gearshape.fill"
        case .unavailable(.modelNotReady):
            return "clock.fill"
        case .unavailable(.deviceNotEligible):
            return "exclamationmark.triangle.fill"
        case .unavailable:
            return "info.circle.fill"
        }
    }

    private var availabilityColor: Color {
        switch model.availability {
        case .available:
            return .statusGreen
        case .unavailable(.appleIntelligenceNotEnabled), .unavailable(.modelNotReady):
            return .statusOrange
        case .unavailable(.deviceNotEligible), .unavailable:
            return .secondary
        }
    }
}

#Preview {
    ContentView()
        .environment(MusicSessionManager())
        .environment(LocationManager())
}
