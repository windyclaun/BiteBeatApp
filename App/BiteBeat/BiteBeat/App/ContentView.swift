import BiteBeatMusic
import SwiftUI

struct ContentView: View {
    @Environment(MusicSessionManager.self) private var musicSession
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if !hasCompletedOnboarding && musicSession.authorizationStatus == .notDetermined {
                AuthorizationView()
                    .transition(.asymmetric(
                        insertion: .identity,
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
            } else {
                HomeView()
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.82), value: hasCompletedOnboarding)
        .animation(.spring(response: 0.6, dampingFraction: 0.82), value: musicSession.authorizationStatus)
        .onAppear {
            musicSession.refreshAuthorizationStatus()
        }
    }
}

#Preview {
    ContentView()
        .environment(MusicSessionManager())
}

