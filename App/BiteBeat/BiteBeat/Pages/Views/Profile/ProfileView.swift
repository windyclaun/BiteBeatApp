import BiteBeatMusic
import SwiftData
import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(MusicSessionManager.self) private var musicSession
    @Query(sort: \MealRecord.selectedAt, order: .reverse) private var mealRecords: [MealRecord]
    @State private var viewModel = ProfileViewModel()
    @State private var showProfileDetails = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                profileHeroView
                historySection
                tasteAnalysisCard
                accountActionsSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 32)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showProfileDetails) {
            ProfileDetailsSheet(
                storefrontCountry: viewModel.storefrontCountry,
                canPlayCatalogContent: musicSession.canPlayCatalogContent,
                onOpenSettings: viewModel.openSystemSettings
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .task {
            await viewModel.fetchRecentSongsAndAnalyze(using: musicSession)
        }
    }

    private var profileHeroView: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 48, height: 48)
                        .background(.white.opacity(0.9), in: Circle())
                        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
                }
                .buttonStyle(.plain)

                Spacer()

                NavigationLink {
                    AboutView()
                } label: {
                    Image(systemName: "info.circle.fill")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.pink)
                        .frame(width: 48, height: 48)
                        .background(.white.opacity(0.9), in: Circle())
                        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, 34)

            Button {
                showProfileDetails = true
            } label: {
                VStack(spacing: 10) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 96))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.pink)

                    HStack(spacing: 8) {
                        Text("Apple Music User")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        Image(systemName: "chevron.right")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(.primary)
                    }

                    Text("Connected with Apple Music")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .padding(.bottom, 24)
        .background(.background, in: RoundedRectangle(cornerRadius: 34, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 18, y: 10)
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                Text("History")
                    .font(.system(size: 30, weight: .bold, design: .rounded))

                Spacer()

                Text("Recent picks")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if mealRecords.isEmpty {
                emptyHistoryCard
            } else {
                VStack(spacing: 14) {
                    ForEach(Array(mealRecords.prefix(3))) { record in
                        historyRow(record)
                    }
                }
            }
        }
    }

    private var emptyHistoryCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 42))
                .foregroundStyle(.pink)

            VStack(alignment: .leading, spacing: 4) {
                Text("No food history yet")
                    .font(.headline.bold())
                Text("Your daily picks will appear here.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(18)
        .background(.background, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 14, y: 8)
    }

    private func historyRow(_ record: MealRecord) -> some View {
        HStack(spacing: 16) {
            FoodImageView(
                directImageURL: record.meal.imageUrl,
                searchQuery: record.meal.photoSearchQuery,
                systemImage: record.mealSystemImage,
                gradientColors: record.meal.swiftUIColors
            )
            .frame(width: 64, height: 64)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.12), radius: 8, y: 4)

            VStack(alignment: .leading, spacing: 5) {
                Text(record.mealTitle)
                    .font(.title3.bold())
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(record.selectedAt.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated).year()))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(18)
        .background(.background, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 14, y: 8)
    }

    private var tasteAnalysisCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "apple.intelligence")
                    .font(.title2)
                    .foregroundStyle(.pink)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Apple Intelligence Vibe")
                        .font(.headline.bold())
                    Text("Dominant Music Persona")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            if viewModel.isLoadingVibe {
                HStack(spacing: 10) {
                    ProgressView()
                        .tint(.pink)
                    Text("Analyzing your taste...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            } else {
                Text(viewModel.dominantVibeName)
                    .font(.title3.bold())
                    .foregroundStyle(.pink.gradient)

                Text(viewModel.dominantVibeDescription)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .background(.background, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 14, y: 8)
    }

    private var accountActionsSection: some View {
        VStack(spacing: 12) {
            Button(role: .destructive) {
                viewModel.openSystemSettings()
            } label: {
                Label("Disconnect Apple Music", systemImage: "rectangle.portrait.and.arrow.right")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.bordered)
            .tint(.red)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Text("Apple Music authorization is managed securely by iOS. To fully revoke access, disable Media & Apple Music in system settings for BiteBeat.")
                .font(.caption)
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
                    .font(.system(size: 104))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.pink)
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
            .background(Color(uiColor: .systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.headline.weight(.semibold))
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
                .font(.body)
                .foregroundStyle(.primary)

            Spacer()

            Text(value)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
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

