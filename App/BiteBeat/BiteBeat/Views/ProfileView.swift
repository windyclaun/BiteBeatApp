import BiteBeatMusic
import SwiftUI

struct ProfileView: View {
    @Environment(MusicSessionManager.self) private var musicSession
    @State private var recentSongs: [BiteMusicTrack] = []
    @State private var dominantVibeName: String = "Loading..."
    @State private var dominantVibeDescription: String = "Loading..."
    @State private var isLoadingVibe = true
    @State private var storefrontCountry = "Loading…"
    
    private static let countries: [String: String] = [
        "id": "Indonesia 🇮🇩",
        "us": "United States 🇺🇸",
        "gb": "United Kingdom 🇬🇧",
        "sg": "Singapore 🇸🇬",
        "my": "Malaysia 🇲🇾",
        "jp": "Japan 🇯🇵",
        "au": "Australia 🇦🇺",
        "ca": "Canada 🇨🇦",
        "de": "Germany 🇩🇪",
        "fr": "France 🇫🇷"
    ]

    var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.pink.gradient)
                        .symbolRenderingMode(.hierarchical)
                        .padding(.top, 8)
                    
                    VStack(spacing: 6) {
                        HStack(spacing: 6) {
                            Image(systemName: "apple.logo")
                            Text("Apple Music User")
                        }
                        .font(.title2.bold())
                        
                        Text(" Secured Account Link")
                            .font(.caption.bold())
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.quaternary, in: Capsule())
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
                        Text(dominantVibeName)
                            .font(.title3.bold())
                            .foregroundStyle(.pink.gradient)
                        
                        Text(dominantVibeDescription)
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
                
                LabeledContent("Storefront") {
                    Text(storefrontCountry)
                        .foregroundStyle(.secondary)
                }
                
                LabeledContent("Play Catalog") {
                    Image(systemName: musicSession.canPlayCatalogContent ? "checkmark.circle.fill" : "xmark.circle")
                        .foregroundStyle(musicSession.canPlayCatalogContent ? .green : .secondary)
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
    
    
    
    private func fetchRecentSongsAndAnalyze() async {
        isLoadingVibe = true
        
        let countryCode = await musicSession.fetchStorefrontCountryCode()
        
        if let code = countryCode {
            let cleanCode = code.lowercased()
            storefrontCountry = Self.countries[cleanCode] ?? cleanCode.uppercased()
        } else {
            storefrontCountry = "Not Available"
        }
        
        do {
            recentSongs = try await musicSession.fetchRecentlyPlayed(limit: 10)
            
            if recentSongs.isEmpty {
                recentSongs = dummySongs
            }
            
            if #available(iOS 26.0, *) {
                let analyzer = MusicToFoodAnalyzer()
                let result = try await analyzer.analyze(songs: recentSongs)
                dominantVibeName = result.vibeName
                dominantVibeDescription = result.vibeDescription
            } else {
                dominantVibeName = "Classic Mix"
                dominantVibeDescription = "Apple Intelligence requires iOS 26.0 or newer."
            }
        } catch {
            dominantVibeName = "Classic Mix"
            dominantVibeDescription = "Failed to load Apple Intelligence insights: \(error.localizedDescription)"
        }
        isLoadingVibe = false
    }
    
    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
    
    private var dummySongs: [BiteMusicTrack] {
        return []
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environment(MusicSessionManager())
    }
}
