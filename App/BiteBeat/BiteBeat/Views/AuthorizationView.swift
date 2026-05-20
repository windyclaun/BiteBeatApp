import BiteBeatMusic
import SwiftUI

struct AuthorizationView: View {
    @Environment(MusicSessionManager.self) private var musicSession
    @State private var isRequesting = false

    @State private var showPermissionDialog = false

    var body: some View {
        ZStack {
            Color.pink
                .ignoresSafeArea()
            
            // Onboard
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
            .blur(radius: showPermissionDialog ? 4 : 0)
            
            // Onboard Permission
            if showPermissionDialog {
                Color.black.opacity(0.05)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                VStack(spacing: 20) {
                    Text("Connect Apple Music")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.black)
                    
                    Text("Allow BiteBeat to access your Apple Music activity to analyze your listening mood")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                        .lineSpacing(2)
                    
                    if musicSession.authorizationStatus == .denied
                        || musicSession.authorizationStatus == .restricted
                    {
                        statusBanner
                    }
                    
                    // Tombol Aksi di bagian bawah Dialog
                    VStack(spacing: 4) {
                        // Tombol Utama: Connect Apple Music
                        Button {
                            requestAccess()
                        } label: {
                            Group {
                                if isRequesting {
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
                        .disabled(isRequesting)
                        
                        // Tombol Alternatif: Not Now
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                showPermissionDialog = false
                            }
                        } label: {
                            Text("Not Now")
                                .font(.subheadline)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(24)
                .frame(width: 320)
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .background(
                            Color.pink.opacity(0.15)
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.15), radius: 25, y: 10)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            musicSession.refreshAuthorizationStatus()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                    showPermissionDialog = true
                }
            }
        }
    }

    @ViewBuilder
    private var statusBanner: some View {
        let message: String = switch musicSession.authorizationStatus {
        case .denied:
            "Access denied. Please check your iOS Settings → Privacy → Media & Apple Music."
        case .restricted:
            "Apple Music access is restricted on this device."
        default:
            ""
        }

        Label(message, systemImage: "exclamationmark.triangle.fill")
            .font(.caption)
            .foregroundStyle(.orange)
            .padding(12)
            .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 10))
    }

    private func requestAccess() {
        if musicSession.authorizationStatus == .denied {
            openSystemSettings()
            return
        }
        
        isRequesting = true
        Task {
            await musicSession.requestAuthorization()
            isRequesting = false
        }
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
}

#Preview {
    AuthorizationView()
        .environment(MusicSessionManager())
}
