import BiteBeatMusic
import SwiftUI

struct AuthorizationView: View {
    @Environment(MusicSessionManager.self) private var musicSession
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var viewModel = AuthorizationViewModel()

    var body: some View {
        ZStack {
            Color.accentColor
                .ignoresSafeArea()

            appLogoView
                .blur(radius: viewModel.showPermissionDialog ? 4 : 0)

            if viewModel.showPermissionDialog {
                dimmingOverlay
                permissionDialogView
            }
        }
        .onAppear {
            viewModel.handleOnAppear(using: musicSession)
        }
    }

    private var appLogoView: some View {
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
    }

    private var dimmingOverlay: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
            .transition(.opacity)
    }

    private var permissionDialogView: some View {
        VStack(spacing: 20) {
            Text("Connect Apple Music")
                .biteBeatFont(.headline)
                .foregroundStyle(.primary)

            Text("Allow BiteBeat to access your Apple Music activity to analyze your listening mood")
                .biteBeatFont(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
                .lineSpacing(2)

            if musicSession.authorizationStatus == .denied
                || musicSession.authorizationStatus == .restricted
            {
                statusBanner
            }

            actionButtonsView
                .padding(.top, 8)
        }
        .padding(24)
        .frame(maxWidth: 340)
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
        .transition(.scale.combined(with: .opacity))
    }

    @ViewBuilder
    private var statusBanner: some View {
        let message = viewModel.getStatusBannerMessage(for: musicSession.authorizationStatus)
        if !message.isEmpty {
            StatusLabel(
                icon: "exclamationmark.triangle.fill",
                message: message,
                color: .statusOrange
            )
        }
    }

    private var actionButtonsView: some View {
        VStack(spacing: 4) {
            Button {
                viewModel.requestAccess(using: musicSession) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        hasCompletedOnboarding = true
                    }
                }
            } label: {
                Group {
                    if viewModel.isRequesting {
                        ProgressView()
                            .tint(.onAccent)
                    } else {
                        Text("Connect Apple Music")
                            .biteBeatFont(.subheadline, weight: .bold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.glassProminent)
            .tint(Color.accentColor)
            .disabled(viewModel.isRequesting)

            Button {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.82)) {
                    hasCompletedOnboarding = true
                }
            } label: {
                Text("Not Now")
                    .biteBeatFont(.subheadline, weight: .bold)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
        }
    }
}

#Preview {
    AuthorizationView()
        .environment(MusicSessionManager())
}
