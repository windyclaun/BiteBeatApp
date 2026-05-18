import BiteBeatMusic
import MusicKit
import SwiftUI

struct HomeView: View {
    @Environment(MusicSessionManager.self) private var musicSession
    
    @State private var recentSongs: [Song] = []
    @State private var isLoadingSongs = true
    @State private var showAnalysis = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What's the vibe for lunch?")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.primary)
                    
                    Text("BiteBeat translates your recent musical taste into personalized nearby lunch recommendations. No decisions, just beats and eats.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 16)
                
                if AppleIntelligenceManager.shared.isAppleIntelligenceActive {
                    HStack(spacing: 6) {
                        Image(systemName: "apple.intelligence")
                            .font(.caption.bold())
                            .foregroundStyle(LinearGradient(
                                colors: [.blue, .purple, .pink, .orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                        Text("POWERED BY APPLE INTELLIGENCE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(uiColor: .secondarySystemGroupedBackground), in: Capsule())
                    .overlay(
                        Capsule()
                            .stroke(LinearGradient(
                                colors: [.blue.opacity(0.3), .purple.opacity(0.3), .pink.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ), lineWidth: 1)
                    )
                    .padding(.bottom, -16)
                }
                
                Button {
                    showAnalysis = true
                } label: {
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: AppleIntelligenceManager.shared.isAppleIntelligenceActive ? "apple.intelligence" : "sparkles")
                                .font(.title)
                                .foregroundStyle(.white)
                                .symbolEffect(.bounce, options: .repeating)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(AppleIntelligenceManager.shared.isAppleIntelligenceActive ? "Analyze with ANE" : "Analyze My Mood")
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(.white)
                                Text(AppleIntelligenceManager.shared.isAppleIntelligenceActive ? "Menggunakan Apple Neural Engine Lokal" : "Get Food Recommendation Now")
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.85))
                            }
                            Spacer()
                            Image(systemName: "chevron.right.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                        }
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(LinearGradient(
                                    colors: AppleIntelligenceManager.shared.isAppleIntelligenceActive ? [.blue, .purple, .pink, .orange] : [.pink, .orange, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .shadow(color: AppleIntelligenceManager.shared.isAppleIntelligenceActive ? .blue.opacity(0.3) : .pink.opacity(0.3), radius: 15, y: 8)
                        }
                    }
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 8) {
                        Image(systemName: "music.note")
                            .foregroundStyle(.pink)
                        Text("Recently Played Vibes")
                            .font(.headline.weight(.semibold))
                        
                        Button {
                            Task {
                                await fetchRecentlyPlayed()
                            }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .font(.subheadline.bold())
                                .foregroundStyle(.pink)
                                .symbolEffect(.bounce, value: isLoadingSongs)
                        }
                        .disabled(isLoadingSongs)
                        
                        Spacer()
                        if recentSongs.isEmpty && !isLoadingSongs {
                            Text("Demo Fallback")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(.quaternary, in: Capsule())
                        }
                    }
                    .padding(.horizontal)
                    
                    if isLoadingSongs {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .padding(.vertical, 30)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(displaySongs.prefix(3), id: \.id) { song in
                                HStack(spacing: 14) {
                                    ArtworkImage(artwork: song.artwork, size: 52)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(song.title)
                                            .font(.body.weight(.medium))
                                            .lineLimit(1)
                                        Text(song.artistName)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }
                                    Spacer()
                                }
                                .padding()
                                .background(.background)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .refreshable {
            await fetchRecentlyPlayed()
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 6) {
                    Image(systemName: "music.note.house.fill")
                        .foregroundStyle(.pink)
                    Text("BiteBeat")
                        .font(.headline.weight(.heavy))
                        .foregroundStyle(.pink.gradient)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: ProfileView()) {
                    Image(systemName: "person.crop.circle")
                        .font(.title3)
                        .foregroundStyle(.pink)
                }
            }
        }
        .fullScreenCover(isPresented: $showAnalysis) {
            AnalysisLoadingView(songsToAnalyze: displaySongs)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ResetHome"))) { _ in
            showAnalysis = false
        }
        .task {
            await fetchRecentlyPlayed()
        }
    }
    
    private var displaySongs: [Song] {
        recentSongs.isEmpty ? mockSongs : recentSongs
    }
    
    private func fetchRecentlyPlayed() async {
        isLoadingSongs = true
        do {
            var request = MusicRecentlyPlayedRequest<Song>()
            request.limit = 10
            let response = try await request.response()
            recentSongs = Array(response.items)
        } catch {
            recentSongs = []
        }
        isLoadingSongs = false
    }
    
    private var mockSongs: [Song] {
        let json = """
        [
          {
            "id": "1",
            "type": "songs",
            "attributes": {
              "name": "Spicy Volcano Groove",
              "artistName": "The Beat Bakers",
              "durationInMillis": 180000,
              "genreNames": ["Pop", "Dance"]
            }
          },
          {
            "id": "2",
            "type": "songs",
            "attributes": {
              "name": "Midnight Carbonara Riffs",
              "artistName": "Truffle Collective",
              "durationInMillis": 240000,
              "genreNames": ["Jazz", "Soul"]
            }
          },
          {
            "id": "3",
            "type": "songs",
            "attributes": {
              "name": "Sweet Berry Acai Ballad",
              "artistName": "Indie Acoustic Dream",
              "durationInMillis": 200000,
              "genreNames": ["Alternative", "Acoustic"]
            }
          }
        ]
        """
        if let data = json.data(using: .utf8),
           let decoded = try? JSONDecoder().decode(MusicItemCollection<Song>.self, from: data) {
            return Array(decoded)
        }
        return []
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environment(MusicSessionManager())
    }
}
