import BiteBeatMusic
import SwiftUI

struct ContentView: View {
    @Environment(MusicSessionManager.self) private var musicSession

    var body: some View {
        Group {
            if musicSession.isAuthorized {
                NavigationStack {
                    HomeView()
                }
            } else {
                AuthorizationView()
            }
        }
        .animation(.easeInOut, value: musicSession.isAuthorized)
        .onAppear {
            musicSession.refreshAuthorizationStatus()
        }
    }
}

#Preview {
    ContentView()
        .environment(MusicSessionManager())
}
