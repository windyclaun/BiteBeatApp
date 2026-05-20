import BiteBeatMusic
import SwiftUI

struct AuthorizationView: View {
    @Environment(MusicSessionManager.self) private var musicSession
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var viewModel = AuthorizationViewModel()

    var body: some View {
        ZStack {
            Color.pink
                .ignoresSafeArea()
            
            // Onboard Background App Branding
            appLogoView
                .blur(radius: viewModel.showPermissionDialog ? 4 : 0)
            
            // Onboard Permission Dialog Overlay
            if viewModel.showPermissionDialog {
                dimmingOverlay
                permissionDialogView
            }
        }
        .onAppear {
            viewModel.handleOnAppear(using: musicSession)
        }
    }

    // MARK: - Subviews

    private var appLogoView: some View {
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
    }

    private var dimmingOverlay: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
            .transition(.opacity)
    }

    private var permissionDialogView: some View {
        VStack(spacing: 20) {
            Text("Connect Apple Music")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Text("Allow BiteBeat to access your Apple Music activity to analyze your listening mood")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
                .lineSpacing(2)
            
            if musicSession.authorizationStatus == .denied
                || musicSession.authorizationStatus == .restricted
            {
                statusBanner
            }
            
            // Action Buttons
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
        .transition(.scale.combined(with: .opacity))
    }

    @ViewBuilder
    private var statusBanner: some View {
        let message = viewModel.getStatusBannerMessage(for: musicSession.authorizationStatus)
        if !message.isEmpty {
            Label(message, systemImage: "exclamationmark.triangle.fill")
                .font(.caption)
                .foregroundStyle(.orange)
                .padding(12)
                .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
        }
    }

    private var actionButtonsView: some View {
        VStack(spacing: 4) {
            // Main Button: Connect Apple Music
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
                            .tint(.white)
                    } else {
                        Text("Connect Apple Music")
                            .font(.subheadline)
                            .bold()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .disabled(viewModel.isRequesting)
            
            // Cancel Button: Not Now
            Button {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.82)) {
                    hasCompletedOnboarding = true
                }
            } label: {
                Text("Not Now")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .bold()
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


