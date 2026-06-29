import BiteBeatMusic
import SwiftUI

struct EndingMealDetailSheet: View {
    @Environment(\.dismiss) private var dismiss

    let meal: Meal

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerView
                    quickFactsView
                    detailSection(title: "Description", text: meal.description)
                    detailSection(title: "Crazy Fun Description", text: meal.crazyFunDescription)

                    if let address = meal.restaurantAddress, !address.isEmpty {
                        detailSection(title: "Address", text: address)
                    }

                    openInMapsButton
                }
                .padding(24)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Meal Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(meal.title)
                .biteBeatFont(.title2, weight: .bold)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Text(meal.restaurantName)
                .biteBeatFont(.subheadline)
                .foregroundStyle(.secondary)

            if let distance = meal.formattedDistance {
                Text(distance)
                    .biteBeatFont(.caption)
                    .foregroundStyle(Color.accentColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var quickFactsView: some View {
        HStack(spacing: 12) {
            factChip(title: "Price", value: meal.price, systemImage: "tag.fill")
            factChip(title: "Calories", value: meal.calories, systemImage: "flame.fill")
        }
    }

    @ViewBuilder
    private var openInMapsButton: some View {
        if meal.latitude != nil && meal.longitude != nil {
            Button {
                Task {
                    await MapsHelper.openInMaps(for: meal)
                }
            } label: {
                Label("Open in Maps", systemImage: "map.fill")
                    .biteBeatFont(.subheadline, weight: .bold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
            }
            .buttonStyle(.glassProminent)
            .tint(Color.accentColor)
        }
    }

    private func factChip(title: String, value: String, systemImage: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .biteBeatFont(.subheadline, weight: .semibold)
                .foregroundStyle(Color.accentColor)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .biteBeatFont(.caption)
                    .foregroundStyle(.secondary)

                Text(value)
                    .biteBeatFont(.subheadline, weight: .semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 14))
    }

    private func detailSection(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .biteBeatFont(.headline)
                .foregroundStyle(.primary)

            Text(text)
                .biteBeatFont(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
    }
}
