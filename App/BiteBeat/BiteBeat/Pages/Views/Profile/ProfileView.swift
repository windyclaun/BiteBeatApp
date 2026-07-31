import BiteBeatMusic
import SwiftUI

struct ProfileView: View {
    @Environment(MusicSessionManager.self) private var musicSession
    @State private var viewModel = ProfileViewModel()
    @State private var showProfileDetails = false
    @State private var showFoodPreferences = false
    @AppStorage(FoodPreferences.appStorageKey) private var foodPreferences = FoodPreferences.default

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                profileHeroView
                preferencesSection
                historySection
                settingsSection
                tasteAnalysisCard
                accountActionsSection
            }
            .screenPadding()
            .padding(.top, 18)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showProfileDetails) {
            ProfileDetailsSheet(
                storefrontCountry: viewModel.storefrontCountry,
                canPlayCatalogContent: musicSession.canPlayCatalogContent,
                onOpenSettings: { SystemSettingsOpener.open() }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showFoodPreferences) {
            FoodPreferencesSheet(preferences: $foodPreferences)
                .presentationDragIndicator(.visible)
        }
        .task {
            await viewModel.fetchRecentSongsAndAnalyze(using: musicSession)
        }
        .onAppear {
            viewModel.refreshMealHistory()
        }
    }

    private var profileHeroView: some View {
        VStack(spacing: 0) {
            HStack {
                NavigationLink {
                    AboutView()
                } label: {
                    Image(systemName: "info.circle.fill")
                        .biteBeatFont(.title3, weight: .semibold)
                        .foregroundStyle(Color.accentColor)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.glass)

                Spacer()
            }
            .padding(.bottom, 34)

            Button {
                showProfileDetails = true
            } label: {
                VStack(spacing: 10) {
                    Image(systemName: "person.crop.circle.fill")
                        .biteBeatFont(.displayLarge)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Color.accentColor)

                    HStack(spacing: 8) {
                        Text("Apple Music User")
                            .biteBeatFont(.title, weight: .bold)
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        Image(systemName: "chevron.right")
                            .biteBeatFont(.headline, weight: .semibold)
                            .foregroundStyle(.primary)
                    }

                    Text("Connected with Apple Music")
                        .biteBeatFont(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
        .cardStyleGroup()
    }

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Preferences", trailing: foodPreferences.hasActivePreferences ? "Active" : "Default")

            Button {
                showFoodPreferences = true
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "slider.horizontal.3")
                        .biteBeatFont(.title)
                        .foregroundStyle(Color.accentColor)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Set Food Preferences")
                            .biteBeatFont(.headline, weight: .bold)
                        Text("Filter recommendations by diet, cuisine, budget & allergens.")
                            .biteBeatFont(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .biteBeatFont(.subheadline, weight: .semibold)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(PreferencesButtonStyle())
        }
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "History", trailing: "Recent picks")

            if viewModel.mealHistory.isEmpty {
                emptyHistoryCard
            } else {
                VStack(spacing: 14) {
                    ForEach(viewModel.mealHistory, id: \.selectedAt) { selection in
                        historyRow(selection)
                    }
                }
            }
        }
    }

    private var emptyHistoryCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "fork.knife.circle.fill")
                .biteBeatFont(.title)
                .foregroundStyle(Color.accentColor)

            VStack(alignment: .leading, spacing: 4) {
                Text("No food history yet")
                    .biteBeatFont(.headline, weight: .bold)
                Text("Your daily picks will appear here.")
                    .biteBeatFont(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .cardStyle()
    }

    private func historyRow(_ selection: DailyMealSelection) -> some View {
        HStack(spacing: 16) {
            FoodImageView(
                mealTitle: selection.meal.title,
                wikipediaQuery: selection.meal.wikipediaSearchQuery,
                fallbackUrl: selection.meal.imageUrl
            )
            .frame(width: 64, height: 64)
            .clipShape(Circle())
            .shadowStyle(radius: 8, y: 4, opacity: 0.12)

            VStack(alignment: .leading, spacing: 5) {
                Text(selection.meal.title)
                    .biteBeatFont(.title3, weight: .bold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(selection.selectedAt.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated).year()))
                    .biteBeatFont(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .cardStyle()
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Settings", trailing: "App")

            VStack(spacing: 0) {
                settingsRow(
                    icon: "info.circle.fill",
                    title: "About",
                    subtitle: "App info & team"
                ) {
                    AboutView()
                }
            }
            .cardStyle()
        }
    }

    private func settingsRow<Destination: View>(
        icon: String,
        title: String,
        subtitle: String,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .biteBeatFont(.title3, weight: .semibold)
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .biteBeatFont(.body, weight: .semibold)
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .biteBeatFont(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .biteBeatFont(.subheadline, weight: .semibold)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var tasteAnalysisCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "apple.intelligence")
                    .biteBeatFont(.title2)
                    .foregroundStyle(Color.accentColor)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Apple Intelligence Vibe")
                        .biteBeatFont(.headline, weight: .bold)
                    Text("Dominant Music Persona")
                        .biteBeatFont(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            if viewModel.isLoadingVibe {
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(Color.accentColor)
                    Text("Analyzing your taste...")
                        .biteBeatFont(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            } else {
                Text(viewModel.dominantVibeName)
                    .biteBeatFont(.title3, weight: .bold)
                    .foregroundStyle(Color.accentColor.gradient)

                Text(viewModel.dominantVibeDescription)
                    .biteBeatFont(.footnote)
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .cardStyle()
    }

    private var accountActionsSection: some View {
        VStack(spacing: 12) {
            Button(role: .destructive) {
                SystemSettingsOpener.open()
            } label: {
                Label("Disconnect Apple Music", systemImage: "rectangle.portrait.and.arrow.right")
                    .biteBeatFont(.subheadline, weight: .bold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.bordered)
            .tint(.statusRed)

            Text("Apple Music authorization is managed securely by iOS. To fully revoke access, disable Media & Apple Music in system settings for BiteBeat.")
                .biteBeatFont(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

private struct ProfileDetailsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let storefrontCountry: String
    let canPlayCatalogContent: Bool
    let onOpenSettings: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 34) {
                Image(systemName: "person.crop.circle.fill")
                    .biteBeatFont(.displayLarge)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color.accentColor)
                    .padding(.top, 20)

                VStack(spacing: 0) {
                    detailRow(title: "Name", value: "Apple Music User")
                    detailRow(title: "Account", value: "Secured Link")
                    detailRow(title: "Storefront", value: storefrontCountry)
                    detailRow(title: "Play Catalog", value: canPlayCatalogContent ? "Available" : "Unavailable")
                    detailRow(title: "AI Vibe", value: "Enabled")
                }
                .padding(.horizontal, 24)

                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .biteBeatFont(.headline, weight: .semibold)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Edit") {
                        onOpenSettings()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .biteBeatFont(.body)
                .foregroundStyle(.primary)

            Spacer()

            Text(value)
                .biteBeatFont(.body)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Image(systemName: "chevron.right")
                .biteBeatFont(.subheadline, weight: .semibold)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 15)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
            .environment(MusicSessionManager())
    }
}

private struct PreferencesButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(.background, in: CornerRadius.large.roundedRect())
            .shadow(color: .black.opacity(0.06), radius: 10, y: 5)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}
