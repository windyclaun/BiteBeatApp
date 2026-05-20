import BiteBeatMusic
import SwiftUI

struct ProfileView: View {
    @Environment(MusicSessionManager.self) private var musicSession
    @State private var viewModel = ProfileViewModel()

    var body: some View {
        List {
            Section {
                profileHeaderView
            }
            .listRowBackground(Color.clear)
            
            Section("Apple Intelligence Vibe") {
                tasteAnalysisView
            }
            
            Section("Apple Music Account") {
                accountDetailsView
            }
            
            Section(footer: ImageAccessWarningFooter) {
                disconnectButtonView
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchRecentSongsAndAnalyze(using: musicSession)
        }
    }
    
    // MARK: - Extracted UI Components
    
    private var profileHeaderView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.pink.gradient)
                .symbolRenderingMode(.hierarchical)
                .padding(.top, 8)
            
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "apple.logo")
                    Text("Apple Music User")
                }
                .font(.title2.bold())
                
                Text(" Secured Account Link")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.quaternary, in: Capsule())
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var tasteAnalysisView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundStyle(.pink)
                
                Text("Dominant Music Persona")
                    .font(.headline.weight(.semibold))
            }
            
            if viewModel.isLoadingVibe {
                HStack {
                    ProgressView()
                    Text("Analyzing your taste…")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 6)
                }
                .padding(.vertical, 8)
            } else {
                Text(viewModel.dominantVibeName)
                    .font(.title3.bold())
                    .foregroundStyle(.pink.gradient)
                
                Text(viewModel.dominantVibeDescription)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 6)
    }
    
    private var accountDetailsView: some View {
        Group {
            LabeledContent("Status") {
                Text("Connected")
                    .foregroundStyle(.green)
                    .bold()
            }
            
            LabeledContent("Storefront") {
                Text(viewModel.storefrontCountry)
                    .foregroundStyle(.secondary)
            }
            
            LabeledContent("Play Catalog") {
                Image(systemName: musicSession.canPlayCatalogContent ? "checkmark.circle.fill" : "xmark.circle")
                    .foregroundStyle(musicSession.canPlayCatalogContent ? .green : .secondary)
            }
        }
    }
    
    private var disconnectButtonView: some View {
        Button(role: .destructive) {
            viewModel.openSystemSettings()
        } label: {
            Label("Disconnect Apple Music", systemImage: "rectangle.portrait.and.arrow.right")
        }
    }
    
    private var ImageAccessWarningFooter: some View {
        Text("Apple Music authorization is managed securely by iOS. To fully revoke access, disable 'Media & Apple Music' in the system settings for BiteBeat.")
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environment(MusicSessionManager())
    }
}

