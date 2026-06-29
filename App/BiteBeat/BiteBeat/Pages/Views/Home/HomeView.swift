import SwiftUI
import BiteBeatMusic
import FoundationModels

extension Notification.Name {
    static let resetHome = Notification.Name("ResetHome")
}

struct HomeView: View {
    @Environment(MusicSessionManager.self) private var musicSession
    @State private var viewModel = HomeViewModel()
    @State private var path = NavigationPath()
    @State private var isPresentingLoading = false
    @State private var expandedOpacity: Double = 1.0
    @State private var scrollResetTrigger = UUID()
    @State private var spreadFactor: CGFloat = 1.0

    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .bottom) {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Home")
                            .biteBeatFont(.title, weight: .bold)
                            .foregroundStyle(.primary)

                        Spacer()

                        NavigationLink {
                            ProfileView()
                        } label: {
                            Image(systemName: "person.crop.circle.fill")
                                .biteBeatFont(.title)
                                .foregroundStyle(Color.accentColor)
                                .frame(width: 36, height: 36)
                                .glassEffect(.regular, in: .circle)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    HStack {
                        Text(musicSession.isAuthorized ? "Recently Played" : "Default Playlist")
                            .biteBeatFont(.headline)
                            .foregroundStyle(.primary)

                        Spacer()

                        if viewModel.isRefreshing {
                            ProgressView()
                                .tint(Color.accentColor)
                                .frame(width: 24, height: 24)
                        } else {
                            Button {
                                Task {
                                    await viewModel.fetchRecentSongs(using: musicSession)
                                }
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .biteBeatFont(.subheadline, weight: .bold)
                                    .foregroundStyle(Color.accentColor)
                                    .frame(width: 24, height: 24)
                            }
                            .buttonStyle(.glass)
                            .accessibilityIdentifier("RefreshButton")
                        }
                    }
                    .padding(.horizontal, 24)

                    ZStack {
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 28) {
                                cardStackView
                                    .onTapGesture {
                                        guard !viewModel.recentSongs.isEmpty else { return }
                                        if !viewModel.isExpanded {
                                            expandedOpacity = 1.0
                                            scrollResetTrigger = UUID()
                                            withAnimation(.spring(response: 0.5, dampingFraction: 0.72, blendDuration: 0)) {
                                                viewModel.isExpanded = true
                                            }
                                        }
                                    }

                                analyzeMoodButton
                                connectionWarning
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 12)
                            .padding(.bottom, 24)
                        }
                        .refreshable {
                            if !viewModel.isExpanded {
                                await viewModel.fetchRecentSongs(using: musicSession)
                            }
                        }
                        .disabled(viewModel.isExpanded)
                        .opacity(viewModel.isExpanded ? (1.0 - expandedOpacity) : 1.0)
                        .offset(y: viewModel.isExpanded ? (expandedOpacity * 80) : 0)
                        .scaleEffect(viewModel.isExpanded ? (0.92 + (1.0 - expandedOpacity) * 0.08) : 1.0)

                        if viewModel.isExpanded {
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(spacing: 16) {
                                    ForEach(viewModel.recentSongs) { song in
                                        SongRow(song: song)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(Color(.secondarySystemGroupedBackground))
                                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                            .padding(.horizontal, 24)
                                    }

                                    Color.clear.frame(height: 120)
                                }
                                .padding(.top, 4)
                            }
                            .id(scrollResetTrigger)
                            .refreshable {
                                await viewModel.fetchRecentSongs(using: musicSession)
                            }
                            .opacity(expandedOpacity)
                            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                                let maxOffset = max(0, geometry.contentSize.height - geometry.containerSize.height)
                                return geometry.contentOffset.y - maxOffset
                            } action: { oldValue, newValue in
                                let overscroll = max(0, newValue)
                                let targetOpacity = max(0.0, 1.0 - (overscroll / 100.0))
                                if expandedOpacity != targetOpacity {
                                    expandedOpacity = targetOpacity
                                }
                            }
                            .onScrollPhaseChange { oldPhase, newPhase, context in
                                if oldPhase == .interacting && (newPhase == .decelerating || newPhase == .idle) {
                                    let geometry = context.geometry
                                    let offset = geometry.contentOffset.y
                                    let maxOffset = max(0, geometry.contentSize.height - geometry.containerSize.height)
                                    if offset > maxOffset + 60 {
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                                            viewModel.isExpanded = false
                                            expandedOpacity = 1.0
                                        }
                                    }
                                }
                                if newPhase == .idle {
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        expandedOpacity = 1.0
                                    }
                                }
                            }
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                }

                if viewModel.isExpanded {
                    analyzeMoodButton
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(.systemGroupedBackground).opacity(0),
                                    Color(.systemGroupedBackground).opacity(0.9),
                                    Color(.systemGroupedBackground)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .ignoresSafeArea()
                        )
                        .opacity(expandedOpacity)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                if isPresentingLoading {
                    AnalysisLoadingView(
                        songsToAnalyze: viewModel.recentSongs,
                        onAnalysisComplete: { vibeName, mainMeal, alternatives, restaurants in
                            withAnimation(.easeInOut) {
                                isPresentingLoading = false
                            }
                            let data = RecommendationData(
                                vibeName: vibeName,
                                vibeDescription: "",
                                mainMeal: mainMeal,
                                alternatives: alternatives,
                                restaurants: restaurants,
                                isMapsFlow: !restaurants.isEmpty
                            )
                            path.append(HomeRoute.recommendation(data))
                        },
                        onCancel: {
                            withAnimation(.easeInOut) {
                                isPresentingLoading = false
                            }
                        }
                    )
                    .ignoresSafeArea()
                    .transition(.opacity)
                }
            }
            .alert("Connect to Apple Music", isPresented: $viewModel.showConnectAlert) {
                if musicSession.authorizationStatus == .denied {
                    Button("Open Settings") {
                        SystemSettingsOpener.open()
                    }
                } else if musicSession.authorizationStatus == .restricted {
                    Button("OK", role: .cancel) {}
                } else {
                    Button("Connect") {
                        Task {
                            await connectAppleMusic()
                            withAnimation(.easeInOut) {
                                isPresentingLoading = true
                            }
                        }
                    }
                }
                Button("Not Now", role: .cancel) {
                    withAnimation(.easeInOut) {
                        isPresentingLoading = true
                    }
                }
            } message: {
                if musicSession.authorizationStatus == .denied {
                    Text("Connecting your Apple Music allows us to analyze your real listening history for a highly personalized food recommendation. Please enable it in Settings.")
                } else {
                    Text("Connecting your Apple Music allows us to analyze your real listening history for a highly personalized food recommendation.")
                }
            }
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .recommendation(let data):
                    RecommendationView(
                        data: data,
                        onSelectMeal: { meal in
                            path.append(HomeRoute.ending(meal))
                        }
                    )
                case .ending(let meal):
                    EndingView(selectedMeal: meal)
                }
            }
            .navigationDestination(for: ProfileRoute.self) { route in
                switch route {
                case .about:
                    AboutView()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .resetHome)) { _ in
                viewModel.refreshSelectedMealToday()
                withAnimation(.easeInOut) {
                    isPresentingLoading = false
                }
                viewModel.isExpanded = false
                path = NavigationPath()
            }
            .task {
                musicSession.refreshAuthorizationStatus()
                await viewModel.fetchRecentSongs(using: musicSession)
            }
            .task {
                while !Task.isCancelled {
                    do {
                        try await Task.sleep(nanoseconds: 4_000_000_000)
                        triggerCardStackAnimation()
                    } catch {
                        break
                    }
                }
            }
            .onAppear {
                viewModel.refreshSelectedMealToday()
                triggerCardStackAnimation()
            }
        }
    }

    private var cardStackView: some View {
        ZStack {
            if viewModel.isRefreshing && viewModel.recentSongs.isEmpty {
                if HomeViewModel.defaultPlaylist.count > 2 {
                    LargeSongCard(song: HomeViewModel.defaultPlaylist[2])
                        .scaleEffect(0.88)
                        .offset(y: -36 * spreadFactor)
                        .rotationEffect(.degrees(-4 * (spreadFactor - 1.0)))
                        .opacity(0.4)
                }
                if HomeViewModel.defaultPlaylist.count > 1 {
                    LargeSongCard(song: HomeViewModel.defaultPlaylist[1])
                        .scaleEffect(0.94)
                        .offset(y: -18 * spreadFactor)
                        .rotationEffect(.degrees(3 * (spreadFactor - 1.0)))
                        .opacity(0.7)
                }
                if let topSong = HomeViewModel.defaultPlaylist.first {
                    LargeSongCard(song: topSong)
                        .rotationEffect(.degrees(-1.5 * (spreadFactor - 1.0)))
                        .shadowStyle(opacity: 0.08)
                }
            } else {
                if viewModel.recentSongs.count > 2 {
                    LargeSongCard(song: viewModel.recentSongs[2])
                        .scaleEffect(0.88)
                        .offset(y: -36 * spreadFactor)
                        .rotationEffect(.degrees(-4 * (spreadFactor - 1.0)))
                        .opacity(0.4)
                }
                if viewModel.recentSongs.count > 1 {
                    LargeSongCard(song: viewModel.recentSongs[1])
                        .scaleEffect(0.94)
                        .offset(y: -18 * spreadFactor)
                        .rotationEffect(.degrees(3 * (spreadFactor - 1.0)))
                        .opacity(0.7)
                }
                if let topSong = viewModel.recentSongs.first {
                    LargeSongCard(song: topSong)
                        .rotationEffect(.degrees(-1.5 * (spreadFactor - 1.0)))
                        .shadowStyle(opacity: 0.08)
                } else {
                    ContentUnavailableView("No Songs Found", systemImage: "music.note", description: Text("Please connect your Apple Music."))
                        .frame(height: 130)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
        }
        .padding(.top, 38)
        .redacted(reason: (viewModel.isRefreshing && viewModel.recentSongs.isEmpty) ? .placeholder : [])
    }

    private var analyzeMoodButton: some View {
        Button {
            viewModel.refreshSelectedMealToday()
            if !viewModel.canAnalyzeToday {
                if let selectedMeal = viewModel.selectedMealToday {
                    path.append(HomeRoute.ending(selectedMeal))
                }
                return
            }
            if musicSession.isAuthorized {
                withAnimation(.easeInOut) {
                    isPresentingLoading = true
                }
            } else {
                viewModel.showConnectAlert = true
            }
        } label: {
            HStack {
                if let selectedMeal = viewModel.selectedMealToday {
                    FoodImageView(
                        mealTitle: selectedMeal.title,
                        wikipediaQuery: selectedMeal.wikipediaSearchQuery,
                        fallbackUrl: selectedMeal.imageUrl
                    )
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                }

                VStack(alignment: .leading, spacing: 4) {
                    if let selectedMeal = viewModel.selectedMealToday {
                        Text(selectedMeal.title)
                            .biteBeatFont(.headline, weight: .bold)
                            .lineLimit(1)
                        Text("Tap to view food details")
                            .biteBeatFont(.caption)
                    } else {
                        Text("Analyze My Mood")
                            .biteBeatFont(.headline, weight: .bold)
                        Text("Get food recommendation now!")
                            .biteBeatFont(.caption)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .biteBeatFont(.title3, weight: .bold)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, viewModel.canAnalyzeToday ? 20 : 16)
        }
        .buttonStyle(.glassProminent)
        .tint(Color.accentColor)
        .buttonBorderShape(.roundedRectangle(radius: 24))
    }

    private func triggerCardStackAnimation() {
        guard !viewModel.isExpanded else { return }
        spreadFactor = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            guard !viewModel.isExpanded else { return }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.55, blendDuration: 0)) {
                spreadFactor = 2.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                guard !viewModel.isExpanded else { return }
                withAnimation(.spring(response: 0.55, dampingFraction: 0.65, blendDuration: 0)) {
                    spreadFactor = 1.0
                }
            }
        }
    }

    private var connectionWarning: some View {
        VStack(spacing: 12) {
            if !musicSession.isAuthorized {
                Button {
                    Task { await connectAppleMusic() }
                } label: {
                    StatusBanner(
                        icon: "music.note",
                        title: appleMusicWarningTitle,
                        subtitle: "These are sample playlists.",
                        tintColor: .statusRed
                    )
                }
                .buttonStyle(.plain)
            }

            if isAppleIntelligenceOff {
                Button {
                    SystemSettingsOpener.openAppleIntelligenceSettings()
                } label: {
                    StatusBanner(
                        icon: "apple.intelligence.badge.xmark",
                        title: "Turn on Apple Intelligence for personalized results.",
                        subtitle: "These are sample recommendations.",
                        tintColor: .statusRed
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var appleMusicWarningTitle: String {
        switch musicSession.authorizationStatus {
        case .denied:
            return "Enable Apple Music access in Settings."
        case .restricted:
            return "Apple Music access is restricted on this device."
        default:
            return "Connect Apple Music to get your listening history."
        }
    }

    private func connectAppleMusic() async {
        musicSession.refreshAuthorizationStatus()
        switch musicSession.authorizationStatus {
        case .notDetermined:
            await musicSession.requestAuthorization()
            await viewModel.fetchRecentSongs(using: musicSession)
        case .denied:
            SystemSettingsOpener.open()
        case .restricted:
            break
        case .authorized:
            await viewModel.fetchRecentSongs(using: musicSession)
        }
    }

    private var isAppleIntelligenceOff: Bool {
        let model = SystemLanguageModel.default
        if case .unavailable(.appleIntelligenceNotEnabled) = model.availability {
            return true
        }
        return false
    }
}

struct LargeSongCard: View {
    let song: BiteMusicTrack

    var body: some View {
        HStack(spacing: 16) {
            ArtworkImage(artworkURL: song.artworkURL, size: 88)
                .shadowStyle(radius: 4, y: 2, opacity: 0.1)

            VStack(alignment: .leading, spacing: 6) {
                Text(song.title)
                    .biteBeatFont(.title3, weight: .bold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(song.artistName)
                    .biteBeatFont(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview {
    HomeView()
        .environment(MusicSessionManager())
        .environment(LocationManager())
}
