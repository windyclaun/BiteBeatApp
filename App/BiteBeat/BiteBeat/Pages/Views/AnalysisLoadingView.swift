import BiteBeatMusic
import SwiftUI

struct AnalysisLoadingView: View {
    @State private var viewModel: AnalysisLoadingViewModel
    
    init(songsToAnalyze: [BiteMusicTrack]) {
        _viewModel = State(initialValue: AnalysisLoadingViewModel(songsToAnalyze: songsToAnalyze))
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            // Complex Core Interactive Animation Group
            interactiveVisualizerGroup
                .frame(height: 350)
                .padding(.bottom, 24)
            
            // Status and Branding area
            statusAndBrandingView
                .frame(height: 80)
                .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationDestination(isPresented: $viewModel.navigateToRecommendation) {
            if let vibeName = viewModel.calculatedVibeName, let main = viewModel.calculatedMain {
                RecommendationView(
                    vibeName: vibeName,
                    mainMeal: main,
                    alternatives: viewModel.calculatedAlternatives
                )
            }
        }
        .task {
            viewModel.startAnalysisAndAnimations()
        }
    }
    
    // MARK: - Extracted Visual Components
    
    private var interactiveVisualizerGroup: some View {
        ZStack {
            // Background pulsing aura/glow
            Circle()
                .fill(LinearGradient(
                    colors: [.pink, .purple, .orange],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 140, height: 140)
                .scaleEffect(viewModel.pulseScale * viewModel.orbScale)
                .blur(radius: 20)
                .opacity(0.6)
            
            // Floating and merging songs from 360 degrees
            FloatingSongsView(
                songs: viewModel.displaySongs,
                progress: viewModel.scrollProgress
            )
            
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
                .scaleEffect(viewModel.orbScale)
                .rotationEffect(.degrees(viewModel.rotateDegree))
            
            // Inner core orb
            Circle()
                .fill(LinearGradient(
                    colors: [.pink, .orange],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 80, height: 80)
                .scaleEffect(viewModel.pulseScale * viewModel.orbScale)
                .overlay {
                    Image(systemName: "sparkles")
                        .font(.system(size: 32))
                        .foregroundStyle(.white)
                        .symbolEffect(.bounce, options: .repeating)
                }
        }
    }
    
    private var statusAndBrandingView: some View {
        VStack(spacing: 8) {
            Text("Apple Intelligence")
                .font(.headline)
                .foregroundStyle(.pink.gradient)
                .textCase(.uppercase)
                .tracking(2.0)
            
            Text(viewModel.loadingStatus)
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
                .contentTransition(.identity)
        }
    }
}

// MARK: - Sub-views

struct FloatingSongsView: View {
    let songs: [BiteMusicTrack]
    let progress: CGFloat
    
    var body: some View {
        ZStack {
            ForEach(Array(songs.enumerated()), id: \.element.id) { index, track in
                let totalCount = Double(songs.count)
                let angle = (Double(index) / totalCount) * 2.0 * .pi
                
                // Staggered convergence progress
                let delay = Double(index) * 0.08
                let adjustedProgress: Double = {
                    if progress <= delay { return 0.0 }
                    let remaining = 1.0 - delay
                    if remaining <= 0 { return 1.0 }
                    return min(1.0, (Double(progress) - delay) / remaining)
                }()
                
                let progressFactor = pow(adjustedProgress, 2.0)
                let initialRadius: CGFloat = 200.0
                let currentRadius = initialRadius * (1.0 - progressFactor)
                
                // Tracing trigonometric coordinates
                let offsetX = currentRadius * cos(angle)
                let offsetY = currentRadius * sin(angle)
                
                // Smooth scaling & opacity transitions
                let scale: CGFloat = {
                    if adjustedProgress == 0.0 { return 0.0 }
                    if currentRadius < 40 { return currentRadius / 40.0 }
                    return 1.0
                }()
                
                let opacity: Double = {
                    if adjustedProgress == 0.0 { return 0.0 }
                    if adjustedProgress < 0.15 { return adjustedProgress / 0.15 }
                    if currentRadius < 40 { return Double(currentRadius / 40.0) }
                    return 1.0
                }()
                
                if adjustedProgress > 0.0 && currentRadius > 5 {
                    SongPillView(track: track)
                        .scaleEffect(scale)
                        .opacity(opacity)
                        .offset(x: offsetX, y: offsetY)
                }
            }
        }
    }
}

struct SongPillView: View {
    let track: BiteMusicTrack
    
    var body: some View {
        HStack(spacing: 8) {
            artworkThumbnail
            
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
    
    @ViewBuilder
    private var artworkThumbnail: some View {
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
    }
}

#Preview {
    NavigationStack {
        AnalysisLoadingView(songsToAnalyze: [])
    }
}

