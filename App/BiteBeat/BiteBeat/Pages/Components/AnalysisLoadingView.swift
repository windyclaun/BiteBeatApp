import SwiftUI
import Observation
import BiteBeatMusic

struct AnalysisLoadingView: View {
    @Environment(MusicSessionManager.self) private var musicSession
    @Environment(LocationManager.self) private var locationManager
    @State private var viewModel: AnalysisLoadingViewModel
    let onAnalysisComplete: @MainActor (String, Meal, [Meal], [RestaurantDishes]) -> Void
    let onCancel: @MainActor () -> Void

    init(songsToAnalyze: [BiteMusicTrack],
         onAnalysisComplete: @escaping @MainActor (String, Meal, [Meal], [RestaurantDishes]) -> Void,
         onCancel: @escaping @MainActor () -> Void) {
        _viewModel = State(initialValue: AnalysisLoadingViewModel(songsToAnalyze: songsToAnalyze))
        self.onAnalysisComplete = onAnalysisComplete
        self.onCancel = onCancel
    }

    var body: some View {
        VStack {
            Spacer()

            interactiveVisualizerGroup
                .frame(height: 350)
                .padding(.bottom, 24)

            statusAndBrandingView
                .padding(.horizontal)

            cancelButton
                .padding(.top, 16)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .task {
            await musicSession.playRandomTrack(from: viewModel.displaySongs)
            viewModel.startAnalysisAndAnimations(using: locationManager) { vibeName, mainMeal, alternatives, restaurants in
                onAnalysisComplete(vibeName, mainMeal, alternatives, restaurants)
            }
        }
        .onDisappear {
            musicSession.pausePlayback()
            viewModel.cancelWorkflow()
        }
    }

    private var interactiveVisualizerGroup: some View {
        ZStack {
            TargetPlayLoadingAnimation(
                pulseScale: viewModel.pulseScale,
                impactScale: viewModel.orbScale
            )
            FloatingSongsView(
                songs: viewModel.displaySongs,
                progress: viewModel.scrollProgress
            )
        }
    }

    private var statusAndBrandingView: some View {
        VStack(spacing: 8) {
            Text("Apple Intelligence")
                .biteBeatFont(.headline)
                .foregroundStyle(Color.accentColor.gradient)
                .textCase(.uppercase)
                .tracking(2.0)

            Text(viewModel.loadingStatus)
                .biteBeatFont(.headline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
                .contentTransition(.identity)
        }
    }

    private var cancelButton: some View {
        Button {
            musicSession.pausePlayback()
            viewModel.cancelWorkflow()
            onCancel()
        } label: {
            Text("Cancel")
                .biteBeatFont(.subheadline, weight: .bold)
                .foregroundStyle(.statusRed)
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
        }
        .buttonStyle(.glass)
    }
}

struct TargetPlayLoadingAnimation: View {
    let pulseScale: CGFloat
    let impactScale: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.accentColor.opacity(0.18), lineWidth: 1)
                .frame(width: 240, height: 240)
                .scaleEffect(1 + ((pulseScale - 0.65) * 0.82))

            targetCircle(size: 184, opacity: 0.18)
            targetCircle(size: 132, opacity: 0.20)
            targetCircle(size: 92, opacity: 0.22)

            Circle()
                .fill(Color.accentColor.opacity(0.34))
                .frame(width: 66, height: 66)
                .scaleEffect(pulseScale * impactScale)

            Image(systemName: "play.fill")
                .biteBeatFont(.title2, weight: .bold)
                .foregroundStyle(Color.accentColor)
                .offset(x: 2)
                .scaleEffect(impactScale)
        }
        .frame(width: 260, height: 260)
    }

    private func targetCircle(size: CGFloat, opacity: Double) -> some View {
        Circle()
            .fill(Color.accentColor.opacity(opacity))
            .frame(width: size, height: size)
            .scaleEffect(1 + ((pulseScale - 0.65) * 0.78))
    }
}

struct FloatingSongsView: View {
    let songs: [BiteMusicTrack]
    let progress: CGFloat

    var body: some View {
        GlassEffectContainer(spacing: 20) {
            ZStack {
                ForEach(Array(songs.enumerated()), id: \.element.id) { index, track in
                    let totalCount = Double(songs.count)
                    let angle = (Double(index) / totalCount) * 2.0 * .pi
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
                    let offsetX = currentRadius * cos(angle)
                    let offsetY = currentRadius * sin(angle)
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
}

struct SongPillView: View {
    let track: BiteMusicTrack

    var body: some View {
        HStack(spacing: 8) {
            artworkThumbnail
            VStack(alignment: .leading, spacing: 1) {
                Text(track.title)
                    .biteBeatFont(.caption2, weight: .bold)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                Text(track.artistName)
                    .biteBeatFont(.caption2)
                    .lineLimit(1)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .glassEffect(.regular, in: .rect(cornerRadius: 16))
    }

    @ViewBuilder
    private var artworkThumbnail: some View {
        if let url = track.artworkURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                case .failure:
                    musicIconThumbnail
                case .empty:
                    loadingThumbnail
                @unknown default:
                    musicIconThumbnail
                }
            }
            .frame(width: 24, height: 24)
            .clipShape(Circle())
        } else {
            musicIconThumbnail
        }
    }

    private var loadingThumbnail: some View {
        Circle()
            .fill(Color.accentColor.opacity(0.16))
            .overlay {
                ProgressView()
                    .scaleEffect(0.55)
                    .tint(Color.accentColor)
            }
    }

    private var musicIconThumbnail: some View {
        Circle()
            .fill(Color.accentColor.opacity(0.1))
            .overlay {
                Image(systemName: "music.note")
                    .biteBeatFont(.caption)
                    .foregroundStyle(Color.accentColor)
            }
            .frame(width: 24, height: 24)
    }
}

@Observable
@MainActor
public final class AnalysisLoadingViewModel {
    public let songsToAnalyze: [BiteMusicTrack]
    public var pulseScale: CGFloat = 0.85
    public var loadingStatus = "Accessing Apple Music History..."
    public var scrollProgress: CGFloat = 0.0
    public var orbScale: CGFloat = 1.0

    private var workflowTask: Task<Void, Never>?
    private var onCompleteCallback: (@MainActor (String, Meal, [Meal], [RestaurantDishes]) -> Void)?

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

    public func startAnalysisAndAnimations(
        using locationManager: LocationManager,
        onComplete: @escaping @MainActor (String, Meal, [Meal], [RestaurantDishes]) -> Void
    ) {
        guard workflowTask == nil else { return }
        self.onCompleteCallback = onComplete

        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            pulseScale = 1.05
        }

        workflowTask = Task {
            await performAnalysisWorkflow(using: locationManager)
        }
    }

    public func cancelWorkflow() {
        workflowTask?.cancel()
        workflowTask = nil
        onCompleteCallback = nil
    }

    private func performAnalysisWorkflow(using locationManager: LocationManager) async {
        loadingStatus = "Locating nearby restaurants..."

        let location = await locationManager.requestAccessAndLocate()
        var nearbyRestaurants: [NearbyRestaurant] = []
        if let loc = location {
            do {
                nearbyRestaurants = try await NearbyRestaurantFinder.search(near: loc, radius: 2000)
            } catch {
                nearbyRestaurants = []
            }
        }

        if Task.isCancelled { return }

        let useMapsFlow = !nearbyRestaurants.isEmpty
        loadingStatus = useMapsFlow
            ? "Found \(nearbyRestaurants.count) nearby restaurants. Analyzing vibes..."
            : "Extracting Music Library Vibes..."

        let analysisTask: Task<(vibeName: String, vibeDescription: String, mainMeal: Meal, alternatives: [Meal], restaurants: [RestaurantDishes]), Never>
        analysisTask = Task {
            let analyzer = MusicToFoodAnalyzer.makeDefault()
            if useMapsFlow {
                do {
                    let result = try await analyzer.analyze(songs: songsToAnalyze, nearbyRestaurants: Array(nearbyRestaurants.prefix(3)))
                    guard let first = result.restaurants.first, let mainDish = first.dishes.first else {
                        return self.fallbackRecommendation(errorMessage: "No dishes found.")
                    }
                    let alternatives: [Meal] = result.restaurants.dropFirst().compactMap { $0.dishes.first }
                    return (result.vibeName, result.vibeDescription, mainDish, alternatives, result.restaurants)
                } catch {
                    return self.fallbackRecommendation(errorMessage: "AI analysis failed, using fallback.")
                }
            } else {
                do {
                    let result = try await analyzer.analyze(songs: songsToAnalyze)
                    return (result.vibeName, result.vibeDescription, result.mainMeal, result.alternatives, [])
                } catch {
                    return self.fallbackRecommendation(errorMessage: "Failed to load from Apple Intelligence.")
                }
            }
        }

        let totalSteps = 100
        let stepDuration = 0.035

        for step in 1...totalSteps {
            if Task.isCancelled { return }
            try? await Task.sleep(nanoseconds: UInt64(stepDuration * 1_000_000_000))
            if Task.isCancelled { return }
            let newProgress = CGFloat(step) / CGFloat(totalSteps)
            withAnimation(.linear(duration: stepDuration)) {
                scrollProgress = newProgress
            }
            triggerOrbScaleBounceIfNeeded(progress: newProgress)

            if step == 30 {
                loadingStatus = "Analyzing Listening Moods..."
            } else if step == 70 {
                loadingStatus = "Merging vibes into recommendation matrix..."
            }
        }

        if Task.isCancelled { return }
        let result = await analysisTask.value
        if Task.isCancelled { return }

        try? await Task.sleep(nanoseconds: 500_000_000)
        if Task.isCancelled { return }

        loadingStatus = "Matched your mood to \(result.vibeName)!"

        try? await Task.sleep(nanoseconds: 800_000_000)
        if Task.isCancelled { return }

        onCompleteCallback?(result.vibeName, result.mainMeal, result.alternatives, result.restaurants)
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

    private func fallbackRecommendation(errorMessage: String) -> (vibeName: String, vibeDescription: String, mainMeal: Meal, alternatives: [Meal], restaurants: [RestaurantDishes]) {
        (
            vibeName: "Classic Mix",
            vibeDescription: errorMessage,
            mainMeal: Meal(
                title: "Nasi Goreng",
                price: "Rp 25.000",
                location: "Warung Kebon (0.1 km)",
                calories: "500 kcal",
                description: "Traditional fried rice with sunny side up egg, crackers, and fresh cucumber slices.",
                crazyFunDescription: "Warning — this meal may trigger spontaneous shoulder dancing."
            ),
            alternatives: [],
            restaurants: []
        )
    }
}

#Preview {
    AnalysisLoadingView(
        songsToAnalyze: [
            BiteMusicTrack(id: "preview-1", title: "Golden Hour", artistName: "Preview Artist", genreNames: ["Pop"], artworkURL: nil),
            BiteMusicTrack(id: "preview-2", title: "Midnight Snacks", artistName: "Kitchen Beats", genreNames: ["R&B"], artworkURL: nil),
            BiteMusicTrack(id: "preview-3", title: "Spicy Loop", artistName: "Synth Chef", genreNames: ["Electronic"], artworkURL: nil)
        ],
        onAnalysisComplete: { _, _, _, _ in },
        onCancel: { }
    )
    .environment(MusicSessionManager())
    .environment(LocationManager())
}
