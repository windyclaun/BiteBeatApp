import SwiftUI
import BiteBeatMusic

struct HomeView: View {
    @Environment(MusicSessionManager.self) private var musicSession
    @State private var viewModel = HomeViewModel()
    @State private var expandedOpacity: Double = 1.0
    @State private var isInteracting = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 20) {
                    // Header Area
                    HStack {
                        Text("Home")
                            .font(.system(.title, design: .rounded))
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
                            .font(.headline)
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
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.pink)
                                    .frame(width: 24, height: 24)
                            }
                            .accessibilityIdentifier("RefreshButton")
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    if !viewModel.isExpanded {
                        // Stacked Cards Mode (large view) - wrapped in ScrollView for pull-to-refresh
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 28) {
                                cardStackView
                                    .onTapGesture {
                                        expandedOpacity = 1.0
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.72, blendDuration: 0)) {
                                            viewModel.isExpanded = true
                                        }
                                    }
                                
                                analyzeMoodButton
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 12)
                            .padding(.bottom, 24)
                        }
                        .refreshable {
                            await viewModel.fetchRecentSongs(using: musicSession)
                        }
                    } else {
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
                        .refreshable {
                            await viewModel.fetchRecentSongs(using: musicSession)
                        }
                        .opacity(expandedOpacity)
                        .onScrollGeometryChange(for: [CGFloat].self) { geometry in
                            [
                                geometry.contentOffset.y,
                                max(0, geometry.contentSize.height - geometry.containerSize.height)
                            ]
                        } action: { oldValue, newValue in
                            let offset = newValue[0]
                            let maxOffset = newValue[1]
                            let overscroll = max(0, offset - maxOffset)
                            
                            // Calculate opacity based on overscroll (fades out as pulled up further)
                            let targetOpacity = max(0.0, 1.0 - (overscroll / 100.0))
                            expandedOpacity = targetOpacity
                            
                            // Only collapse if the user is actively dragging (not on momentum/deceleration)
                            if isInteracting && offset > maxOffset + 60 {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                                    viewModel.isExpanded = false
                                    expandedOpacity = 1.0
                                }
                            }
                        }
                        .onScrollPhaseChange { oldPhase, newPhase in
                            isInteracting = (newPhase == .interacting)
                            
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
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                if viewModel.navigateToLoading {
                    AnalysisLoadingView(
                        songsToAnalyze: viewModel.recentSongs,
                        onAnalysisComplete: { vibeName, mainMeal, alternatives in
                            viewModel.calculatedVibeName = vibeName
                            viewModel.calculatedMain = mainMeal
                            viewModel.calculatedAlternatives = alternatives
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
                } else {
                    Button("Connect") {
                        Task {
                            await musicSession.requestAuthorization()
                            await viewModel.fetchRecentSongs(using: musicSession)
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
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ResetHome"))) { _ in
                withAnimation(.easeInOut) {
                    viewModel.navigateToLoading = false
                }
                viewModel.isExpanded = false
                viewModel.navigateToRecommendation = false
                viewModel.calculatedVibeName = nil
                viewModel.calculatedMain = nil
                viewModel.calculatedAlternatives = []
            }
            .task {
                if musicSession.authorizationStatus == .notDetermined {
                    await musicSession.requestAuthorization()
                }
                await viewModel.fetchRecentSongs(using: musicSession)
            }
        }
    }
    
    private var cardStackView: some View {
        ZStack {
            if viewModel.recentSongs.count > 2 {
                LargeSongCard(song: viewModel.recentSongs[2])
                    .scaleEffect(0.88)
                    .offset(y: -36)
                    .opacity(0.4)
            }
            
            if viewModel.recentSongs.count > 1 {
                LargeSongCard(song: viewModel.recentSongs[1])
                    .scaleEffect(0.94)
                    .offset(y: -18)
                    .opacity(0.7)
            }
            
            if let topSong = viewModel.recentSongs.first {
                LargeSongCard(song: topSong)
                    .shadow(color: .black.opacity(0.08), radius: 10, y: 5)
            } else {
                // Placeholder in case song data is empty during initial load
                ContentUnavailableView("No Songs Found", systemImage: "music.note", description: Text("Please connect your Apple Music."))
                    .frame(height: 130)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
        .padding(.top, 38)
    }
    
    private var analyzeMoodButton: some View {
        Button {
            if musicSession.isAuthorized {
                withAnimation(.easeInOut) {
                    viewModel.navigateToLoading = true
                }
            } else {
                viewModel.showConnectAlert = true
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Analyze My Mood")
                        .font(.headline)
                        .bold()
                    Text("Get food recommendation now !")
                        .font(.caption)
                        .opacity(0.9)
                }
                .foregroundStyle(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.title3.bold())
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.pink)
            )
            .shadow(color: .pink.opacity(0.3), radius: 10, y: 6)
        }
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
                    .font(.title3.bold())
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                Text(song.artistName)
                    .font(.subheadline)
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
    HomeView()
        .environment(MusicSessionManager())
}

