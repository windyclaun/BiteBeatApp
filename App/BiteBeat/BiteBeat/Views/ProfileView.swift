import BiteBeatMusic
import MusicKit
import SwiftUI

struct ProfileView: View {
    @Environment(MusicSessionManager.self) private var musicSession
    @State private var recentSongs: [Song] = []
    @State private var dominantVibe: MusicVibe = .comfortingWarm
    @State private var isLoadingVibe = true

    var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.pink.gradient)
                        .symbolRenderingMode(.hierarchical)
                        .padding(.top, 8)
                    
                    VStack(spacing: 4) {
                        Text("Music Foodie")
                            .font(.title2.bold())
                        Text("premium.user@bitebeat.app")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
            
            Section("Apple Intelligence Vibe") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.title2)
                            .foregroundStyle(.pink)
                        
                        Text("Dominant Music Persona")
                            .font(.headline.weight(.semibold))
                    }
                    
                    if isLoadingVibe {
                        HStack {
                            ProgressView()
                            Text("Analyzing your taste…")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .padding(.leading, 6)
                        }
                        .padding(.vertical, 8)
                    } else {
                        Text(dominantVibe.rawValue)
                            .font(.title3.bold())
                            .foregroundStyle(.pink.gradient)
                        
                        Text(vibeDescription(for: dominantVibe))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.vertical, 6)
            }
            
            Section("Apple Music Account") {
                LabeledContent("Status") {
                    Text("Connected")
                        .foregroundStyle(.green)
                        .bold()
                }
                
                if let subscription = musicSession.musicSubscription {
                    LabeledContent("Play Catalog") {
                        Image(systemName: subscription.canPlayCatalogContent ? "checkmark.circle.fill" : "xmark.circle")
                            .foregroundStyle(subscription.canPlayCatalogContent ? .green : .secondary)
                    }
                }
            }
            
            Section(footer: Text("Apple Music authorization is managed securely by iOS. To fully revoke access, disable 'Media & Apple Music' in the system settings for BiteBeat.")) {
                Button(role: .destructive) {
                    openSystemSettings()
                } label: {
                    Label("Disconnect Apple Music", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await fetchRecentSongsAndAnalyze()
        }
    }
    
    private func vibeDescription(for vibe: MusicVibe) -> String {
        switch vibe {
        case .vibrantSpicy:
            return "Your playlist is loaded with hot beats and pop grooves! Apple Intelligence says you need bold spices, energy-boosting meals, and fun tacos to fuel your day."
        case .comfortingWarm:
            return "Smooth jazz, lo-fi beats, and warm vocals fill your queue. Cozy pasta, warm soups, and comforting local classics will match your relaxing vibe."
        case .indulgentSweet:
            return "You appreciate emotional depth, acoustic strings, and sweet ballads. Treat yourself to rich waffles, sweet acai bowls, or pancakes to feed your soul."
        case .cleanFresh:
            return "Your playlist leans classical, clean, and focus-inducing. A fresh, healthy poke bowl or superfood quinoa salad is the perfect mindful pairing."
        case .boldHearty:
            return "Heavy riffs, fast tempos, and bold rock/metal tracks dominate your player. Go big with a double cheeseburger, pepperoni pizza, or BBQ ribs today!"
        }
    }
    
    private func fetchRecentSongsAndAnalyze() async {
        isLoadingVibe = true
        do {
            var request = MusicRecentlyPlayedRequest<Song>()
            request.limit = 10
            let response = try await request.response()
            recentSongs = Array(response.items)
            
            if recentSongs.isEmpty {
                recentSongs = dummySongs
            }
            
            let analyzer = MusicToFoodAnalyzer()
            let result = analyzer.analyze(songs: recentSongs)
            dominantVibe = result.vibe
        } catch {
            dominantVibe = .comfortingWarm
        }
        isLoadingVibe = false
    }
    
    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
    
    private var dummySongs: [Song] {
        return []
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environment(MusicSessionManager())
    }
}
