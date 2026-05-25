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
                if #available(iOS 26.0, *) {
                    AppleIntelligencePermissionView(hasAcknowledgedAppleIntelligence: $hasAcknowledgedAppleIntelligence)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        ))
                } else {
                    AppleIntelligenceInfoView(hasAcknowledgedAppleIntelligence: $hasAcknowledgedAppleIntelligence)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        ))
                }
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

@available(iOS 26.0, *)
private struct AppleIntelligencePermissionView: View {
    @Binding var hasAcknowledgedAppleIntelligence: Bool
    private let model = SystemLanguageModel.default

    var body: some View {
        ZStack {
            Color.pink
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Spacer()

                Image("LogoApp")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundStyle(.white)

                Text("BiteBeat")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Spacer()
            }
            .blur(radius: 4)

            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "apple.intelligence")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(.pink)

                Text("Apple Intelligence")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)

                Text("BiteBeat uses on-device Apple Intelligence to understand your music vibe and turn it into a food recommendation.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                    .lineSpacing(2)

                statusBanner

                actionButtonsView
                    .padding(.top, 8)
            }
            .padding(24)
            .frame(width: 320)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(uiColor: .systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color(uiColor: .separator), lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.15), radius: 20, y: 8)
        }
    }

    private var statusBanner: some View {
        Label(availabilityMessage, systemImage: availabilityIcon)
            .font(.caption)
            .foregroundStyle(availabilityColor)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(availabilityColor.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
    }

    private var actionButtonsView: some View {
        VStack(spacing: 4) {
            if AppleIntelligenceHelper.isNotEnabled {
                Button {
                    openSystemSettings()
                } label: {
                    Text("Open Settings")
                        .font(.subheadline)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(.pink)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                Button {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.82)) {
                        hasAcknowledgedAppleIntelligence = true
                    }
                } label: {
                    Text("Continue")
                        .font(.subheadline)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(.pink)
                .clipShape(RoundedRectangle(cornerRadius: 14))
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
            return .green
        case .unavailable(.appleIntelligenceNotEnabled), .unavailable(.modelNotReady):
            return .orange
        case .unavailable(.deviceNotEligible), .unavailable:
            return .secondary
        }
    }

    private func openSystemSettings() {
        if let globalSettingsURL = URL(string: "App-Prefs:") {
            UIApplication.shared.open(globalSettingsURL, options: [:]) { success in
                if !success {
                    if let appSettingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(appSettingsURL)
                    }
                }
            }
        } else if let appSettingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(appSettingsURL)
        }
    }
}

private struct AppleIntelligenceInfoView: View {
    @Binding var hasAcknowledgedAppleIntelligence: Bool

    var body: some View {
        ZStack {
            Color.pink
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "sparkles")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(.pink)

                Text("Apple Intelligence")
                    .font(.headline)
                    .fontWeight(.bold)

                Text("BiteBeat uses Apple Intelligence on supported devices to match your music vibe with food recommendations.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)

                Button {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.82)) {
                        hasAcknowledgedAppleIntelligence = true
                    }
                } label: {
                    Text("Continue")
                        .font(.subheadline)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(.pink)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.top, 8)
            }
            .padding(24)
            .frame(width: 320)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(uiColor: .systemBackground))
            )
            .shadow(color: .black.opacity(0.15), radius: 20, y: 8)
        }
    }
}

#Preview {
    ContentView()
        .environment(MusicSessionManager())
}

