import SwiftUI
import BiteBeatMusic
import FoundationModels

struct HomeView: View {
    @Environment(MusicSessionManager.self) private var musicSession
    @AppStorage("hasAcknowledgedAppleIntelligence") private var hasAcknowledgedAppleIntelligence = true
    @State private var viewModel = HomeViewModel()
    @State private var expandedOpacity: Double = 1.0
    @State private var isInteracting = false
    @State private var scrollResetTrigger = UUID()
    @State private var spreadFactor: CGFloat = 1.0
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 20) {
                    // Header Area
                    HStack {
                        Text("Home")
                            .biteBeatFont(.title)
                            .bold()
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        NavigationLink(destination: ProfileView()) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundStyle(.pink)
                                .padding(4)
                                .background(.background, in: Circle())
                                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                        }
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
                                .tint(.pink)
                                .frame(width: 24, height: 24)
                        } else {
                            Button {
                                Task {
                                    await viewModel.fetchRecentSongs(using: musicSession)
                                }
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .biteBeatFont(.subheadline, weight: .bold)
                                    .foregroundStyle(.pink)
                                    .frame(width: 24, height: 24)
                            }
                            .accessibilityIdentifier("RefreshButton")
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    ZStack {
                        // Stacked Cards Mode (large view) - wrapped in ScrollView for pull-to-refresh
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 28) {
                                cardStackView
                                    .onTapGesture {
                                        guard !viewModel.recentSongs.isEmpty else { return }
                                        if !viewModel.isExpanded {
                                            expandedOpacity = 1.0
                                            scrollResetTrigger = UUID() // Force fresh ScrollView on expand
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
                            // Expanded Scrollable List Mode (normal/smaller view)
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(spacing: 16) {
                                    ForEach(viewModel.recentSongs) { song in
                                        SongRow(song: song)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                            .padding(.horizontal, 24)
                                    }
                                    
                                    Color.clear.frame(height: 120)
                                }
                                .padding(.top, 4)
                            }
                            .id(scrollResetTrigger) // Force a completely fresh scroll offset when opened
                            .refreshable {
                                await viewModel.fetchRecentSongs(using: musicSession)
                            }
                            .opacity(expandedOpacity)
                            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                                let maxOffset = max(0, geometry.contentSize.height - geometry.containerSize.height)
                                return geometry.contentOffset.y - maxOffset
                            } action: { oldValue, newValue in
                                let overscroll = max(0, newValue)
                                
                                // Highly optimized: only update state if opacity actually changes, preventing jitter during normal fast scrolling
                                let targetOpacity = max(0.0, 1.0 - (overscroll / 100.0))
                                if expandedOpacity != targetOpacity {
                                    expandedOpacity = targetOpacity
                                }
                            }
                            .onScrollPhaseChange { oldPhase, newPhase, context in
                                isInteracting = (newPhase == .interacting)
                                
                                // Only close when the user actually releases their finger (interacting -> decelerating/idle)
                                // and the final drag position was past the threshold (+60)
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
                                
                                // Smoothly animate opacity back to 1.0 if the user releases without collapsing
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
                    // Pinned to the bottom overlay when expanded
                    analyzeMoodButton
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(uiColor: .systemGroupedBackground).opacity(0),
                                    Color(uiColor: .systemGroupedBackground).opacity(0.9),
                                    Color(uiColor: .systemGroupedBackground)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .ignoresSafeArea()
                        )
                        .opacity(expandedOpacity)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                if viewModel.navigateToLoading {
                    AnalysisLoadingView(
                        songsToAnalyze: viewModel.recentSongs,
                        onAnalysisComplete: { vibeName, mainMeal, alternatives in
                            viewModel.calculatedVibeName = vibeName
                            viewModel.calculatedMain = mainMeal
                            viewModel.calculatedAlternatives = alternatives
                            viewModel.navigateToLoading = false
                            viewModel.navigateToRecommendation = true
                        },
                        onCancel: {
                            withAnimation(.easeInOut) {
                                viewModel.navigateToLoading = false
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
                        viewModel.openSystemSettings()
                    }
                } else if musicSession.authorizationStatus == .restricted {
                    Button("OK", role: .cancel) {}
                } else {
                    Button("Connect") {
                        Task {
                            await connectAppleMusic()
                            withAnimation(.easeInOut) {
                                viewModel.navigateToLoading = true
                            }
                        }
                    }
                }
                
                Button("Not Now", role: .cancel) {
                    withAnimation(.easeInOut) {
                        viewModel.navigateToLoading = true
                    }
                }
            } message: {
                if musicSession.authorizationStatus == .denied {
                    Text("Connecting your Apple Music allows us to analyze your real listening history for a highly personalized food recommendation. Please enable it in Settings.")
                } else {
                    Text("Connecting your Apple Music allows us to analyze your real listening history for a highly personalized food recommendation.")
                }
            }
            .navigationDestination(isPresented: $viewModel.navigateToRecommendation) {
                if let vibeName = viewModel.calculatedVibeName, let main = viewModel.calculatedMain {
                    RecommendationView(
                        vibeName: vibeName,
                        mainMeal: main,
                        alternatives: viewModel.calculatedAlternatives
                    )
                }
            }
            .navigationDestination(isPresented: $viewModel.navigateToSavedMeal) {
                if let selectedMeal = viewModel.selectedMealToday {
                    EndingView(selectedMeal: selectedMeal)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ResetHome"))) { _ in
                viewModel.refreshSelectedMealToday()
                withAnimation(.easeInOut) {
                    viewModel.navigateToLoading = false
                }
                viewModel.isExpanded = false
                viewModel.navigateToRecommendation = false
                viewModel.navigateToSavedMeal = false
                viewModel.calculatedVibeName = nil
                viewModel.calculatedMain = nil
                viewModel.calculatedAlternatives = []
            }
            .task {
                musicSession.refreshAuthorizationStatus()
                await viewModel.fetchRecentSongs(using: musicSession)
            }
            .task {
                // Periodically wiggle/nudge the card stack every 8 seconds to remind the user it is interactive
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
                // Skeleton loading state
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
                        .shadow(color: .black.opacity(0.08), radius: 10, y: 5)
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
                        .shadow(color: .black.opacity(0.08), radius: 10, y: 5)
                } else {
                    // Placeholder in case song data is empty during initial load
                    ContentUnavailableView("No Songs Found", systemImage: "music.note", description: Text("Please connect your Apple Music."))
                        .frame(height: 130)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
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
                viewModel.navigateToSavedMeal = true
                return
            }

            if musicSession.isAuthorized {
                withAnimation(.easeInOut) {
                    viewModel.navigateToLoading = true
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
                            .biteBeatFont(.headline)
                            .bold()
                            .lineLimit(1)
                        Text("Tap to view food details")
                            .biteBeatFont(.caption)
                            .opacity(0.9)
                    } else {
                        Text("Analyze My Mood")
                            .biteBeatFont(.headline)
                            .bold()
                        Text("Get food recommendation now !")
                            .biteBeatFont(.caption)
                            .opacity(0.9)
                    }
                }
                .foregroundStyle(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .biteBeatFont(.title3, weight: .bold)
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, viewModel.canAnalyzeToday ? 20 : 16)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.pink)
            )
            .shadow(
                color: Color.pink,
                radius: 10,
                y: 6
            )
        }
    }
    
    private func triggerCardStackAnimation() {
        guard !viewModel.isExpanded else { return }
        
        // Reset to initial state
        spreadFactor = 1.0
        
        // Brief delay after appearing, then spread out
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            guard !viewModel.isExpanded else { return }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.55, blendDuration: 0)) {
                spreadFactor = 2.0 // Cards spread apart (merenggang)
            }
            
            // Snap back together
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                guard !viewModel.isExpanded else { return }
                withAnimation(.spring(response: 0.55, dampingFraction: 0.65, blendDuration: 0)) {
                    spreadFactor = 1.0 // Cards close back together (merapat)
                }
            }
        }
    }
    
    private var connectionWarning: some View {
        VStack(spacing: 12) {
            if !musicSession.isAuthorized {
                        Button {
                            Task {
                                await connectAppleMusic()
                            }
                        } label: {
                            warningBanner(
                                icon: "music.note",
                                subtitle: "These are sample playlists.",
                                title: appleMusicWarningTitle
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    if isAppleIntelligenceOff {
                        Button {
                            openSystemSettings()
                        } label: {
                            warningBanner(
                                icon: "apple.intelligence.badge.xmark",
                                subtitle: "These are sample recommendations.",
                                title: "Turn on Apple Intelligence for personalized results."
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
            openSystemSettings()
        case .restricted:
            break
        case .authorized:
            await viewModel.fetchRecentSongs(using: musicSession)
        }
    }

    private func warningBanner(
        icon: String,
        subtitle: String,
        title: String,
        action: (() -> Void)? = nil
    ) -> some View {
        Group {
            if let action {
                Button(action: action) {
                    warningBannerContent(icon: icon, subtitle: subtitle, title: title)
                }
                .buttonStyle(.plain)
            } else {
                warningBannerContent(icon: icon, subtitle: subtitle, title: title)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.pink.opacity(0.35))
        )
    }

    private func warningBannerContent(
        icon: String,
        subtitle: String,
        title: String
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .biteBeatFont(.custom(22), weight: .semibold)
                .foregroundStyle(.red)

            VStack(alignment: .leading, spacing: 2) {
                Text(subtitle)
                    .biteBeatFont(.custom(11), weight: .light)
                    .foregroundStyle(.red)

                Text(title)
                    .biteBeatFont(.custom(11), weight: .bold)
                    .foregroundStyle(.red)
            }

            Spacer()
        }
    }
    
    private var isAppleIntelligenceOff: Bool {
        guard #available(iOS 26.0, *) else {
            return false
        }

        let model = SystemLanguageModel.default
        if case .unavailable(.appleIntelligenceNotEnabled) = model.availability {
            return true
        }

        return false
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
}

struct LargeSongCard: View {
    let song: BiteMusicTrack
    
    var body: some View {
        HStack(spacing: 16) {
            ArtworkImage(artworkURL: song.artworkURL, size: 88)
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
            
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
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview {
    if #available(iOS 26.0, *) {
        HomeView()
            .environment(MusicSessionManager())
    } else {
        // Fallback on earlier versions
    }
}

