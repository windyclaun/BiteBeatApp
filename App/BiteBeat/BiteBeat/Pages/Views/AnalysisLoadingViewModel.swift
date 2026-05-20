//
//  AnalysisLoadingViewModel.swift
//  BiteBeat
//

import SwiftUI
import Observation
import BiteBeatMusic

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
    public var navigateToRecommendation = false
    
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
    
    public func startAnalysisAndAnimations() {
        // Start continuous background visual effects
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            pulseScale = 1.05
        }
        withAnimation(.linear(duration: 3.5).repeatForever(autoreverses: false)) {
            rotateDegree = 360.0
        }
        
        // Execute heavy workflow asynchronously
        Task {
            await performAnalysisWorkflow()
        }
    }
    
    private func performAnalysisWorkflow() async {
        // Start backend analysis service task
        let analysisTask = Task { () -> (vibeName: String, vibeDescription: String, mainMeal: Meal, alternatives: [Meal]) in
            if #available(iOS 26.0, *) {
                let analyzer = MusicToFoodAnalyzer()
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
            try? await Task.sleep(nanoseconds: UInt64(stepDuration * 1_000_000_000))
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
        
        // Wait for both animation sequence and analytical API results to finalize
        let result = await analysisTask.value
        calculatedVibeName = result.vibeName
        calculatedVibeDescription = result.vibeDescription
        calculatedMain = result.mainMeal
        calculatedAlternatives = result.alternatives
        
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        if let vibe = calculatedVibeName {
            loadingStatus = "Matched your mood to \(vibe)!"
        }
        
        try? await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds
        navigateToRecommendation = true
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
