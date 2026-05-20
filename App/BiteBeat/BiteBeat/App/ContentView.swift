import BiteBeatMusic
import SwiftUI

struct ContentView: View {
    @Environment(MusicSessionManager.self) private var musicSession

    var body: some View {
        HomeView()
            .onAppear {
                musicSession.refreshAuthorizationStatus()
            }
    }
}

#Preview {
    ContentView()
        .environment(MusicSessionManager())
}
