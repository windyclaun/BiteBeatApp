//
//  AnalysisLoadingView.swift
//  BiteBeat
//
//  Created by Apple Developer Academy.
//

import SwiftUI
import Observation
import BiteBeatMusic

struct AnalysisLoadingView: View {
    @State private var viewModel: AnalysisLoadingViewModel
    let onAnalysisComplete: @MainActor (String, Meal, [Meal]) -> Void
    let onCancel: @MainActor () -> Void
    
    init(songsToAnalyze: [BiteMusicTrack],
         onAnalysisComplete: @escaping @MainActor (String, Meal, [Meal]) -> Void,
         onCancel: @escaping @MainActor () -> Void) {
        _viewModel = State(initialValue: AnalysisLoadingViewModel(songsToAnalyze: songsToAnalyze))
        self.onAnalysisComplete = onAnalysisComplete
        self.onCancel = onCancel
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
            
            cancelButton
                .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
        .task {
            viewModel.startAnalysisAndAnimations { vibeName, mainMeal, alternatives in
                onAnalysisComplete(vibeName, mainMeal, alternatives)
            }
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
    
    private var cancelButton: some View {
        Button {
            viewModel.cancelWorkflow()
            onCancel()
        } label: {
            Text("Cancel")
                .font(.subheadline.bold())
                .foregroundStyle(.pink)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .stroke(Color.pink.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

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

@Observable
@MainActor
public final class AnalysisLoadingViewModel {
    public let songsToAnalyze: [BiteMusicTrack]
    
    // UI Animation properties
    public var pulseScale: CGFloat = 0.85
    public var rotateDegree = 0.0
    public var loadingStatus = "Accessing Apple Music History…"
    public var scrollProgress: CGFloat = 0.0
    public var orbScale: CGFloat = 1.0
    
    // Output states
    public var calculatedVibeName: String?
    public var calculatedVibeDescription: String?
    public var calculatedMain: Meal?
    public var calculatedAlternatives: [Meal] = []
    
    private var workflowTask: Task<Void, Never>?
    private var onCompleteCallback: (@MainActor (String, Meal, [Meal]) -> Void)?
    
    public init(songsToAnalyze: [BiteMusicTrack]) {
        self.songsToAnalyze = songsToAnalyze
    }
    
    public var displaySongs: [BiteMusicTrack] {
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
    
    public func startAnalysisAndAnimations(onComplete: @escaping @MainActor (String, Meal, [Meal]) -> Void) {
        self.onCompleteCallback = onComplete
        
        // Start continuous background visual effects
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            pulseScale = 1.05
        }
        withAnimation(.linear(duration: 3.5).repeatForever(autoreverses: false)) {
            rotateDegree = 360.0
        }
        
        // Execute heavy workflow asynchronously
        workflowTask = Task {
            await performAnalysisWorkflow()
        }
    }
    
    public func cancelWorkflow() {
        workflowTask?.cancel()
    }
    
    private func performAnalysisWorkflow() async {
        // Start backend analysis service task
        let analysisTask = Task { () -> (vibeName: String, vibeDescription: String, mainMeal: Meal, alternatives: [Meal]) in
            if #available(iOS 26.0, *) {
                let analyzer = MusicToFoodAnalyzer.makeDefault()
                do {
                    return try await analyzer.analyze(songs: songsToAnalyze)
                } catch {
                    return self.fallbackRecommendation(errorMessage: "Failed to load from Apple Intelligence.")
                }
            } else {
                return self.fallbackRecommendation(errorMessage: "Apple Intelligence requires iOS 26.0 or newer.")
            }
        }
        
        // Progress steps for float-and-merge spiral animation
        loadingStatus = "Extracting Music Library Vibes…"
        
        let totalSteps = 100
        let stepDuration = 0.035 // 3.5 seconds total
        
        for step in 1...totalSteps {
            if Task.isCancelled { return }
            try? await Task.sleep(nanoseconds: UInt64(stepDuration * 1_000_000_000))
            if Task.isCancelled { return }
            
            let newProgress = CGFloat(step) / CGFloat(totalSteps)
            
            withAnimation(.linear(duration: stepDuration)) {
                scrollProgress = newProgress
            }
            
            // Detect single song convergence & trigger impact pulse animation
            triggerOrbScaleBounceIfNeeded(progress: newProgress)
            
            if step == 30 {
                loadingStatus = "Analyzing Listening Moods…"
            } else if step == 70 {
                loadingStatus = "Merging vibes into recommendation matrix…"
            }
        }
        
        if Task.isCancelled { return }
        // Wait for both animation sequence and analytical API results to finalize
        let result = await analysisTask.value
        if Task.isCancelled { return }
        
        calculatedVibeName = result.vibeName
        calculatedVibeDescription = result.vibeDescription
        calculatedMain = result.mainMeal
        calculatedAlternatives = result.alternatives
        
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        if Task.isCancelled { return }
        
        if let vibe = calculatedVibeName {
            loadingStatus = "Matched your mood to \(vibe)!"
        }
        
        try? await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds
        if Task.isCancelled { return }
        
        // Finalize transition via completion callback
        if let vibeName = calculatedVibeName, let main = calculatedMain {
            onCompleteCallback?(vibeName, main, calculatedAlternatives)
        }
    }
    
    private func triggerOrbScaleBounceIfNeeded(progress: CGFloat) {
        let songs = displaySongs
        for i in 0..<songs.count {
            let delay = Double(i) * 0.08
            let adjustedProgress: Double = {
                if progress <= delay { return 0.0 }
                let remaining = 1.0 - delay
                if remaining <= 0 { return 1.0 }
                return min(1.0, (Double(progress) - delay) / remaining)
            }()
            let progressFactor = pow(adjustedProgress, 2.0)
            let currentR = 200.0 * (1.0 - progressFactor)
            
            // Trigger quick scale bump when passing the merge boundary
            if adjustedProgress > 0.0 && currentR < 15 && currentR > 10 {
                withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) {
                    orbScale = 1.25
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                        self.orbScale = 1.0
                    }
                }
            }
        }
    }
    
    private func fallbackRecommendation(errorMessage: String) -> (vibeName: String, vibeDescription: String, mainMeal: Meal, alternatives: [Meal]) {
        return (
            vibeName: "Classic Mix",
            vibeDescription: errorMessage,
            mainMeal: Meal(
                title: "Fallback Nasi Goreng",
                price: "Rp 25.000",
                location: "Warung Kebon (0.1 km)",
                calories: "500 kcal",
                description: "Nasi goreng kecap tradisional dengan telur mata sapi renyah, kerupuk, dan irisan mentimun segar.",
                systemImage: "flame.fill",
                gradientColors: ["orange", "red"]
            ),
            alternatives: []
        )
    }
}
