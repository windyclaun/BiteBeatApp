import SwiftUI
import BiteBeatMusic

struct HomeView: View {
    @Environment(MusicSessionManager.self) private var musicSession
    @State private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 20) {
                    // Header Area
                    HStack {
                        Text("BiteBeat")
                            .font(.system(.title, design: .rounded))
                            .bold()
                            .foregroundStyle(.pink)
                        
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
                    
                    Text(musicSession.isAuthorized ? "Recently Played" : "Default Playlist")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 24)
                    
                    if !viewModel.isExpanded {
                        // Tumpukan Kartu
                        cardStackView
                            .onTapGesture {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.72, blendDuration: 0)) {
                                    viewModel.isExpanded = true
                                }
                            }
                            .padding(.horizontal, 24)
                        
                        Spacer()
                    } else {
                        // Daftar yang bisa di-scroll
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
                                
                                Button {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                                        viewModel.isExpanded = false
                                    }
                                } label: {
                                    Text("Collapse Stack")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .padding()
                                }
                                
                                Color.clear.frame(height: 120)
                            }
                            .padding(.top, 4)
                        }
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                
                analyzeMoodButton
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
            }
            .navigationDestination(isPresented: $viewModel.navigateToLoading) {
                AnalysisLoadingView(songsToAnalyze: viewModel.recentSongs)
            }
            .alert("Connect to Apple Music", isPresented: $viewModel.showConnectAlert) {
                Button("Connect") {
                    Task {
                        await musicSession.requestAuthorization()
                        await viewModel.fetchRecentSongs(using: musicSession)
                        viewModel.navigateToLoading = true
                    }
                }
                Button("Not Now", role: .cancel) {
                    viewModel.navigateToLoading = true
                }
            } message: {
                Text("Connecting your Apple Music allows us to analyze your real listening history for a highly personalized food recommendation.")
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ResetHome"))) { _ in
                viewModel.navigateToLoading = false
                viewModel.isExpanded = false
            }
            .task {
                await viewModel.fetchRecentSongs(using: musicSession)
            }
        }
    }
    
    private var cardStackView: some View {
        ZStack {
            if viewModel.recentSongs.count > 2 {
                SongRow(song: viewModel.recentSongs[2])
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .scaleEffect(0.90)
                    .offset(y: -24)
                    .opacity(0.4)
            }
            
            if viewModel.recentSongs.count > 1 {
                SongRow(song: viewModel.recentSongs[1])
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .scaleEffect(0.95)
                    .offset(y: -12)
                    .opacity(0.7)
            }
            
            if let topSong = viewModel.recentSongs.first {
                SongRow(song: topSong)
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.08), radius: 10, y: 5)
            } else {
                // Placeholder seandainya data lagu kosong saat awal loading
                ContentUnavailableView("No Songs Found", systemImage: "music.note", description: Text("Please connect your Apple Music."))
                    .frame(height: 90)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(.top, 24)
    }
    
    private var analyzeMoodButton: some View {
        Button {
            if musicSession.isAuthorized {
                viewModel.navigateToLoading = true
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

#Preview {
    HomeView()
        .environment(MusicSessionManager())
}
