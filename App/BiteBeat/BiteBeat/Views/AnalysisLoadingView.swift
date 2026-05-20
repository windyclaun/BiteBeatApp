import BiteBeatMusic
import SwiftUI

struct AnalysisLoadingView: View {
    let songsToAnalyze: [BiteMusicTrack]
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var pulseScale: CGFloat = 0.85
    @State private var rotateDegree = 0.0
    @State private var loadingStatus = "Accessing Apple Music History…"
    @State private var calculatedVibeName: String?
    @State private var calculatedVibeDescription: String?
    @State private var calculatedMain: Meal?
    @State private var calculatedAlternatives: [Meal] = []
    
    @State private var navigateToRecommendation = false
    
    // States for custom float-and-merge animation
    @State private var scrollProgress: CGFloat = 0.0
    @State private var orbScale: CGFloat = 1.0
    
    private var displaySongs: [BiteMusicTrack] {
        if songsToAnalyze.isEmpty {
            return [
                BiteMusicTrack(id: "mock1", title: "Lofi Chill Beats", artistName: "Beatmaker", genreNames: [], artworkURL: nil),
                BiteMusicTrack(id: "mock2", title: "Midnight Whispers", artistName: "Vibe Queen", genreNames: [], artworkURL: nil),
                BiteMusicTrack(id: "mock3", title: "Golden Hour Sunset", artistName: "Acoustic Sun", genreNames: [], artworkURL: nil),
                BiteMusicTrack(id: "mock4", title: "Retro Grid Drive", artistName: "Retro Rider", genreNames: [], artworkURL: nil),
                BiteMusicTrack(id: "mock5", title: "Late Night Jazz", artistName: "Jazz Quartet", genreNames: [], artworkURL: nil)
            ]
        }
        return songsToAnalyze
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                // Background aura/glow
                Circle()
                    .fill(LinearGradient(
                        colors: [.pink, .purple, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 140, height: 140)
                    .scaleEffect(pulseScale * orbScale)
                    .blur(radius: 20)
                    .opacity(0.6)
                
                // Floating and merging songs from all directions (360 degrees)
                ForEach(Array(displaySongs.enumerated()), id: \.element.id) { index, track in
                    let totalCount = Double(displaySongs.count)
                    let angle = (Double(index) / totalCount) * 2.0 * .pi
                    
                    // Stagger the start based on index for smooth consecutive spiral convergence
                    let delay = Double(index) * 0.08
                    let adjustedProgress: Double = {
                        if scrollProgress <= delay { return 0.0 }
                        let remaining = 1.0 - delay
                        if remaining <= 0 { return 1.0 }
                        return min(1.0, (Double(scrollProgress) - delay) / remaining)
                    }()
                    
                    let progressFactor = pow(adjustedProgress, 2.0)
                    let initialR: CGFloat = 200.0
                    let currentR = initialR * (1.0 - progressFactor)
                    
                    // Compute high-performance X/Y coordinates
                    let offsetX = currentR * cos(angle)
                    let offsetY = currentR * sin(angle)
                    
                    // Smooth scaling & opacity based on current radius distance
                    let scale: CGFloat = {
                        if adjustedProgress == 0.0 { return 0.0 }
                        if currentR < 40 {
                            return currentR / 40.0
                        }
                        return 1.0
                    }()
                    
                    let opacity: Double = {
                        if adjustedProgress == 0.0 { return 0.0 }
                        if adjustedProgress < 0.15 {
                            return adjustedProgress / 0.15
                        }
                        if currentR < 40 {
                            return Double(currentR / 40.0)
                        }
                        return 1.0
                    }()
                    
                    if adjustedProgress > 0.0 && currentR > 5 {
                        SongPillView(track: track)
                            .scaleEffect(scale)
                            .opacity(opacity)
                            .offset(x: offsetX, y: offsetY)
                    }
                }
                
                // Rotating outer ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.pink, .purple, .orange, .pink],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 6
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(orbScale)
                    .rotationEffect(.degrees(rotateDegree))
                
                // Inner core orb
                Circle()
                    .fill(LinearGradient(
                        colors: [.pink, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                    .scaleEffect(pulseScale * orbScale)
                    .overlay {
                        Image(systemName: "sparkles")
                            .font(.system(size: 32))
                            .foregroundStyle(.white)
                            .symbolEffect(.bounce, options: .repeating)
                    }
            }
            .frame(height: 350)
            .padding(.bottom, 24)
            
            VStack(spacing: 8) {
                Text("Apple Intelligence")
                    .font(.headline)
                    .foregroundStyle(.pink.gradient)
                    .textCase(.uppercase)
                    .tracking(2.0)
                
                Text(loadingStatus)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .contentTransition(.identity)
            }
            .frame(height: 80)
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationDestination(isPresented: $navigateToRecommendation) {
            if let vibeName = calculatedVibeName, let main = calculatedMain {
                RecommendationView(
                    vibeName: vibeName,
                    mainMeal: main,
                    alternatives: calculatedAlternatives
                )
            }
        }
        .task {
            // Background pulsing & spinning
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulseScale = 1.05
            }
            withAnimation(.linear(duration: 3.5).repeatForever(autoreverses: false)) {
                rotateDegree = 360.0
            }
            
            // Start loading & API call asynchronously
            async let fetchResult: Void = {
                if #available(iOS 26.0, *) {
                    let analyzer = MusicToFoodAnalyzer()
                    do {
                        let result = try await analyzer.analyze(songs: songsToAnalyze)
                        calculatedVibeName = result.vibeName
                        calculatedVibeDescription = result.vibeDescription
                        calculatedMain = result.mainMeal
                        calculatedAlternatives = result.alternatives
                    } catch {
                        calculatedVibeName = "Error Analyzing"
                        calculatedVibeDescription = "Failed to load from Apple Intelligence."
                        calculatedMain = Meal(title: "Fallback Nasi Goreng", price: "Rp 25.000", location: "-", calories: "-", description: "-", systemImage: "flame.fill", gradientColors: ["orange", "red"])
                        calculatedAlternatives = []
                    }
                } else {
                    calculatedVibeName = "Classic Mix"
                    calculatedVibeDescription = "Apple Intelligence requires iOS 26.0 or newer."
                    calculatedMain = Meal(title: "Fallback Nasi Goreng", price: "Rp 25.000", location: "-", calories: "-", description: "-", systemImage: "flame.fill", gradientColors: ["orange", "red"])
                    calculatedAlternatives = []
                }
            }()
            
            // Animate scroll progress from 0.0 to 1.0 over 3.5 seconds
            loadingStatus = "Extracting Music Library Vibes…"
            
            let totalSteps = 100
            let stepDuration = 0.035 // 3.5 seconds total
            
            for step in 1...totalSteps {
                await sleep(stepDuration)
                let newProgress = CGFloat(step) / CGFloat(totalSteps)
                
                withAnimation(.linear(duration: stepDuration)) {
                    scrollProgress = newProgress
                }
                
                // Detect when a song merges (currentR < 15)
                for i in 0..<displaySongs.count {
                    let delay = Double(i) * 0.08
                    let adjustedProgress: Double = {
                        if newProgress <= delay { return 0.0 }
                        let remaining = 1.0 - delay
                        if remaining <= 0 { return 1.0 }
                        return min(1.0, (Double(newProgress) - delay) / remaining)
                    }()
                    let progressFactor = pow(adjustedProgress, 2.0)
                    let currentR = 200.0 * (1.0 - progressFactor)
                    
                    if adjustedProgress > 0.0 && currentR < 15 && currentR > 10 {
                        withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) {
                            orbScale = 1.25
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                                orbScale = 1.0
                            }
                        }
                    }
                }
                
                if step == 30 {
                    loadingStatus = "Analyzing Listening Moods…"
                } else if step == 70 {
                    loadingStatus = "Merging vibes into recommendation matrix…"
                }
            }
            
            // Wait for both the API call to finish and the minimum animation to complete
            _ = await fetchResult
            
            await sleep(0.5)
            if let vibe = calculatedVibeName {
                loadingStatus = "Matched your mood to \(vibe)!"
            }
            
            await sleep(0.8)
            navigateToRecommendation = true
        }
    }
    
    private func sleep(_ seconds: TimeInterval) async {
        try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}

struct SongPillView: View {
    let track: BiteMusicTrack
    
    var body: some View {
        HStack(spacing: 8) {
            if let url = track.artworkURL {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    Color.pink.opacity(0.2)
                }
                .frame(width: 24, height: 24)
                .clipShape(Circle())
            } else {
                Image(systemName: "music.note")
                    .font(.caption)
                    .foregroundStyle(.pink)
                    .frame(width: 24, height: 24)
                    .background(Color.pink.opacity(0.1))
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading, spacing: 1) {
                Text(track.title)
                    .font(.caption2.bold())
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                Text(track.artistName)
                    .font(.system(size: 8))
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(uiColor: .systemBackground).opacity(0.85))
                .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.pink.opacity(0.15), lineWidth: 0.5)
        )
    }
}

#Preview {
    NavigationStack {
        AnalysisLoadingView(songsToAnalyze: [])
    }
}
