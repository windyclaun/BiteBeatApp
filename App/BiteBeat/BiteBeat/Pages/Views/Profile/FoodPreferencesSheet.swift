import SwiftUI
import Observation

struct FoodPreferencesSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var draft: FoodPreferences
    @Binding private var preferences: FoodPreferences

    init(preferences: Binding<FoodPreferences>) {
        _preferences = preferences
        _draft = State(initialValue: preferences.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    introCard
                    dietSection
                    cuisineSection
                    budgetSection
                    allergensSection
                    moodSection
                    resetSection
                }
                .screenPadding()
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
            .background(Color(.systemGroupedBackground))
            .safeAreaInset(edge: .bottom) {
                saveBar
            }
            .navigationTitle("Food Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .biteBeatFont(.subheadline, weight: .semibold)
                }
            }
        }
        .presentationDragIndicator(.visible)
    }

    private var introCard: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "slider.horizontal.3")
                .biteBeatFont(.title2)
                .foregroundStyle(Color.accentColor)
                .frame(width: 44, height: 44)
                .glassEffect(.regular, in: .rect(cornerRadius: CornerRadius.large.rawValue))

            VStack(alignment: .leading, spacing: 6) {
                Text("Shape your meal matches")
                    .biteBeatFont(.headline, weight: .bold)
                Text("These preferences filter every recommendation so it fits your diet, taste, and budget.")
                    .biteBeatFont(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .cardStyle()
    }

    private var dietSection: some View {
        preferenceSection(
            title: "Diet",
            subtitle: "Pick the one that fits you"
        ) {
            VStack(spacing: 0) {
                ForEach(Array(FoodPreferences.Diet.allCases.enumerated()), id: \.element.id) { index, option in
                    singleSelectRow(
                        option: option,
                        isSelected: draft.diet == option
                    ) {
                        draft.diet = option
                    }
                    if index < FoodPreferences.Diet.allCases.count - 1 {
                        Divider().padding(.leading, 56)
                    }
                }
            }
        }
    }

    private var cuisineSection: some View {
        preferenceSection(
            title: "Cuisine",
            subtitle: "Preferred flavor origin"
        ) {
            VStack(spacing: 0) {
                ForEach(Array(FoodPreferences.Cuisine.allCases.enumerated()), id: \.element.id) { index, option in
                    singleSelectRow(
                        option: option,
                        isSelected: draft.cuisine == option
                    ) {
                        draft.cuisine = option
                    }
                    if index < FoodPreferences.Cuisine.allCases.count - 1 {
                        Divider().padding(.leading, 56)
                    }
                }
            }
        }
    }

    private var budgetSection: some View {
        preferenceSection(
            title: "Budget",
            subtitle: "Keep prices within range"
        ) {
            VStack(spacing: 0) {
                ForEach(Array(FoodPreferences.Budget.allCases.enumerated()), id: \.element.id) { index, option in
                    singleSelectRow(
                        option: option,
                        isSelected: draft.maxBudget == option
                    ) {
                        draft.maxBudget = option
                    }
                    if index < FoodPreferences.Budget.allCases.count - 1 {
                        Divider().padding(.leading, 56)
                    }
                }
            }
        }
    }

    private var allergensSection: some View {
        preferenceSection(
            title: "Allergens to Avoid",
            subtitle: "We'll never recommend dishes with these"
        ) {
            chipGrid(options: Array(FoodPreferences.Allergen.allCases), selection: draft.allergens) { option in
                toggleSelection(option, in: \.allergens)
            }
        }
    }

    private var moodSection: some View {
        preferenceSection(
            title: "Flavor Moods",
            subtitle: "Lean toward the vibes you love"
        ) {
            chipGrid(options: Array(FoodPreferences.MoodTag.allCases), selection: draft.preferredMoods) { option in
                toggleSelection(option, in: \.preferredMoods)
            }
        }
    }

    private var resetSection: some View {
        Button(role: .destructive) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                draft = .default
            }
        } label: {
            Label("Reset to Defaults", systemImage: "arrow.counterclockwise")
                .biteBeatFont(.subheadline, weight: .bold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
        }
        .buttonStyle(.glass)
        .tint(.statusRed)
    }

    private var saveBar: some View {
        VStack(spacing: 0) {
            Divider()
            PrimaryActionButton(title: "Save Preferences") {
                preferences = draft
                dismiss()
            }
            .padding(.horizontal, ScreenPadding.horizontal)
            .padding(.vertical, 14)
        }
        .background(.regularMaterial)
    }

    private func preferenceSection<Content: View>(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .biteBeatFont(.title3, weight: .bold)
                Spacer()
                Text(subtitle)
                    .biteBeatFont(.caption)
                    .foregroundStyle(.secondary)
            }

            content()
                .cardStyle(cornerRadius: .xl)
        }
    }

    private func singleSelectRow<Option: Identifiable & Hashable & FoodPreferencesSelectable>(
        option: Option,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: option.systemImage)
                    .biteBeatFont(.body)
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary)
                    .frame(width: 32)

                Text(option.label)
                    .biteBeatFont(.body, weight: isSelected ? .bold : .regular)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .biteBeatFont(.title3)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(isSelected ? Color.accentColor : Color(.tertiaryLabel))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.vertical, 13)
    }

    private func chipGrid<Option: Identifiable & Hashable & FoodPreferencesSelectable>(
        options: [Option],
        selection: Set<Option>,
        onTap: @escaping (Option) -> Void
    ) -> some View {
        GlassEffectContainer(spacing: Spacing.sm.rawValue) {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 72), spacing: Spacing.sm.rawValue)],
                spacing: Spacing.sm.rawValue
            ) {
                ForEach(options) { option in
                    let selected = selection.contains(option)
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            onTap(option)
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: option.systemImage)
                                .biteBeatFont(.title3, weight: .semibold)
                            Text(option.label)
                                .biteBeatFont(.caption, weight: selected ? .bold : .medium)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, minHeight: 72)
                        .foregroundStyle(selected ? Color.accentColor : .primary)
                    }
                    .buttonStyle(.glass)
                    .tint(selected ? Color.accentColor : .clear)
                }
            }
        }
    }

    private func toggleSelection<Option: Hashable>(
        _ option: Option,
        in keyPath: WritableKeyPath<FoodPreferences, Set<Option>>
    ) {
        if draft[keyPath: keyPath].contains(option) {
            draft[keyPath: keyPath].remove(option)
        } else {
            draft[keyPath: keyPath].insert(option)
        }
    }
}

protocol FoodPreferencesSelectable {
    var label: String { get }
    var systemImage: String { get }
}

extension FoodPreferences.Diet: FoodPreferencesSelectable {
    var label: String { rawValue }
}
extension FoodPreferences.Cuisine: FoodPreferencesSelectable {
    var label: String { rawValue }
}
extension FoodPreferences.Budget: FoodPreferencesSelectable {
    var label: String { rawValue }
}
extension FoodPreferences.Allergen: FoodPreferencesSelectable {
    var label: String { rawValue }
}
extension FoodPreferences.MoodTag: FoodPreferencesSelectable {
    var label: String { shortLabel }
}

#Preview {
    FoodPreferencesSheet(preferences: .constant(.default))
}