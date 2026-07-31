import BiteBeatMusic
import MapKit
import SwiftUI

struct RecommendationView: View {
    @State private var viewModel: RecommendationViewModel
    private let onSelectMeal: (Meal) -> Void

    init(data: RecommendationData, onSelectMeal: @escaping (Meal) -> Void) {
        _viewModel = State(initialValue: RecommendationViewModel(data: data))
        self.onSelectMeal = onSelectMeal
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if viewModel.choseNay {
                    alternativesSelectionView
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity.combined(with: .move(edge: .trailing))
                        ))
                } else if viewModel.isMapsFlow {
                    mapsRecommendationView
                } else {
                    mainRecommendationView
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .leading)),
                            removal: .opacity.combined(with: .move(edge: .leading))
                        ))
                }
            }
            .padding(.horizontal, 36)
            .padding(.top, 118)
            .padding(.bottom, 36)
        }
        .background(Color(.systemBackground))
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Maps Flow

    private var mapsRecommendationView: some View {
        VStack(spacing: 0) {
            Text("Nearby Matches")
                .biteBeatFont(.title2, weight: .bold)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)

            Text(viewModel.vibeName)
                .biteBeatFont(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.bottom, 20)

            mapView
                .frame(height: 260)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal, -4)

            Text("Menu suggested by AI")
                .biteBeatFont(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 8)
                .padding(.bottom, 24)

            MealHeroImage(meal: viewModel.mainMeal, size: 200)
                .padding(.bottom, 24)

            mealSummary(for: viewModel.mainMeal)
                .padding(.bottom, 16)

            restaurantChipsRow
                .padding(.bottom, 32)

            mapsActionButtons
        }
        .sheet(isPresented: Binding(
            get: { viewModel.drillInRestaurantIndex != nil },
            set: { if !$0 { viewModel.closeDrillIn() } }
        )) {
            if let restaurant = viewModel.drillInRestaurant {
                drillInSheet(for: restaurant)
            }
        }
    }

    private var mapView: some View {
        Map(position: $viewModel.mapPosition) {
            ForEach(Array(viewModel.restaurants.enumerated()), id: \.element.id) { index, rd in
                Annotation(rd.restaurant.name, coordinate: rd.restaurant.coordinate) {
                    Button {
                        viewModel.openDrillIn(for: rd)
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.accentColor.gradient)
                                .frame(width: 36, height: 36)
                            Text("\(index + 1)")
                                .biteBeatFont(.subheadline, weight: .bold)
                                .foregroundStyle(Color.onAccent)
                        }
                        .shadowStyle(radius: 3, y: 1, opacity: 0.2)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .mapControls {
            MapCompass()
            MapScaleView()
        }
    }

    private var restaurantChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(viewModel.restaurants.enumerated()), id: \.element.id) { index, rd in
                    Button {
                        viewModel.openDrillIn(for: rd)
                    } label: {
                        HStack(spacing: 6) {
                            Text("\(index + 1)")
                                .biteBeatFont(.caption2, weight: .bold)
                                .foregroundStyle(Color.onAccent)
                                .frame(width: 20, height: 20)
                                .background(Color.accentColor, in: Circle())

                            VStack(alignment: .leading, spacing: 1) {
                                Text(rd.restaurant.name)
                                    .biteBeatFont(.caption, weight: .semibold)
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)

                                if let distance = rd.dishes.first?.formattedDistance {
                                    Text(distance)
                                        .biteBeatFont(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.glass)
                    .buttonBorderShape(.capsule)
                }
            }
        }
    }

    private func drillInSheet(for restaurant: RestaurantDishes) -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(restaurant.restaurant.name)
                            .biteBeatFont(.title2, weight: .bold)
                            .foregroundStyle(.primary)

                        if !restaurant.restaurant.address.isEmpty {
                            Text(restaurant.restaurant.address)
                                .biteBeatFont(.caption)
                                .foregroundStyle(.secondary)
                        }

                        if let dist = restaurant.dishes.first?.formattedDistance {
                            Text(dist)
                                .biteBeatFont(.caption)
                                .foregroundStyle(Color.accentColor)
                        }
                    }

                    Text("Menu suggested by AI")
                        .biteBeatFont(.caption)
                        .foregroundStyle(.secondary)

                    ForEach(restaurant.dishes) { dish in
                        Button {
                            viewModel.closeDrillIn()
                            onSelectMeal(dish)
                        } label: {
                            dishRowCard(dish)
                        }
                        .buttonStyle(.plain)
                    }

                    openInMapsButton(for: restaurant.restaurant)
                }
                .padding(24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Restaurant Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        viewModel.closeDrillIn()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func dishRowCard(_ dish: Meal) -> some View {
        HStack(spacing: 14) {
            FoodImageView(
                mealTitle: dish.title,
                wikipediaQuery: dish.wikipediaSearchQuery,
                fallbackUrl: dish.imageUrl
            )
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(dish.title)
                    .biteBeatFont(.subheadline, weight: .bold)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                HStack(spacing: 10) {
                    Text(dish.price)
                        .biteBeatFont(.caption)
                        .foregroundStyle(.secondary)

                    Text(dish.calories)
                        .biteBeatFont(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .biteBeatFont(.caption, weight: .semibold)
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func openInMapsButton(for restaurant: NearbyRestaurant) -> some View {
        Button {
            Task {
                let meal = Meal(
                    title: restaurant.name,
                    price: "",
                    location: restaurant.name,
                    calories: "",
                    description: "",
                    realRestaurantName: restaurant.name,
                    restaurantAddress: restaurant.address,
                    latitude: restaurant.coordinate.latitude,
                    longitude: restaurant.coordinate.longitude,
                    distanceInMeters: restaurant.distanceInMeters,
                    mapItemIdentifier: restaurant.mapItemIdentifier
                )
                await viewModel.openInMaps(meal)
            }
        } label: {
            Label("Open in Maps", systemImage: "map.fill")
                .biteBeatFont(.subheadline, weight: .bold)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
        }
        .buttonStyle(.glassProminent)
        .tint(Color.accentColor)
        .padding(.top, 8)
    }

    private var mapsActionButtons: some View {
        VStack(spacing: 10) {
            PrimaryActionButton(title: "Yay!") {
                onSelectMeal(viewModel.mainMeal)
            }

            SecondaryActionButton(title: "Nay!") {
                viewModel.toggleShowAlternatives(show: true)
            }
        }
    }

    // MARK: - Legacy Card Flow

    private var mainRecommendationView: some View {
        VStack(spacing: 0) {
            Text("Your Best Lunch Match")
                .biteBeatFont(.title2, weight: .bold)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 34)

            MealHeroImage(meal: viewModel.mainMeal, size: 264)

            mealSummary(for: viewModel.mainMeal)
                .padding(.top, 42)

            legacyActionButtons
                .padding(.top, 44)

            locationBanner
                .padding(.top, 16)
        }
    }

    private var legacyActionButtons: some View {
        VStack(spacing: 10) {
            PrimaryActionButton(title: "Yay!") {
                onSelectMeal(viewModel.mainMeal)
            }

            SecondaryActionButton(title: "Nay!") {
                viewModel.toggleShowAlternatives(show: true)
            }
        }
    }

    private var alternativesSelectionView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Pick Another Match")
                    .biteBeatFont(.title2, weight: .bold)
                    .foregroundStyle(.primary)

                Text("Choose one meal that fits your mood better.")
                    .biteBeatFont(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(viewModel.alternatives) { meal in
                            Button {
                                viewModel.selectAlternativeCard(meal)
                            } label: {
                                alternativeCard(for: meal, isSelected: viewModel.selectedAlternative?.id == meal.id)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if let selectedAlternative = viewModel.selectedAlternative {
                        alternativeDescriptionBox(for: selectedAlternative)
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(maxHeight: 430)

            alternativeActionButtons
                .padding(.top, 8)
        }
    }

    private var alternativeActionButtons: some View {
        VStack(spacing: 10) {
            PrimaryActionButton(title: "Yay!") {
                if let selectedAlternative = viewModel.selectedAlternative {
                    onSelectMeal(selectedAlternative)
                }
            }
            .disabled(viewModel.selectedAlternative == nil)

            SecondaryActionButton(title: "Back to Best Match") {
                viewModel.resetToMainSelection()
            }
        }
    }

    // MARK: - Shared Components

    private var locationBanner: some View {
        Group {
            if !viewModel.isMapsFlow {
                HStack(spacing: 8) {
                    Image(systemName: "location.slash")
                        .biteBeatFont(.caption)
                        .foregroundStyle(.secondary)

                    Text("Enable location for real nearby restaurants.")
                        .biteBeatFont(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .glassEffect(in: .rect(cornerRadius: 12))
                .padding(.top, 4)
            }
        }
    }

    private func mealSummary(for meal: Meal) -> some View {
        VStack(spacing: 18) {
            Text(meal.title)
                .biteBeatFont(.title, weight: .bold)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.78)

            HStack(spacing: 18) {
                InfoItem(systemImage: "creditcard", text: meal.price)
                InfoItem(systemImage: "map", text: meal.restaurantName)
                InfoItem(systemImage: "list.clipboard", text: meal.calories)
            }
            .frame(maxWidth: .infinity)

            descriptionScrollView(meal.description)
        }
    }

    private func descriptionScrollView(_ description: String) -> some View {
        ScrollView(.vertical, showsIndicators: true) {
            Text(description)
                .biteBeatFont(.callout)
                .foregroundStyle(Color(.systemGray))
                .lineSpacing(3)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 2)
        }
        .frame(height: 88)
        .scrollBounceBehavior(.basedOnSize)
    }

    private func alternativeDescriptionBox(for meal: Meal) -> some View {
        VStack(spacing: 16) {
            mealSummary(for: meal)
        }
        .padding(.top, 4)
        .transition(.opacity.combined(with: .scale(scale: 0.96)))
    }

    private func alternativeCard(for meal: Meal, isSelected: Bool) -> some View {
        VStack(spacing: 10) {
            MealHeroImage(meal: meal, size: 88)

            Text(meal.title)
                .biteBeatFont(.caption, weight: .bold)
                .foregroundStyle(isSelected ? Color.accentColor : .primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 34)

            Text(meal.price)
                .biteBeatFont(.caption2, weight: .semibold)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(isSelected ? Color.accentColor : Color(.systemGray5), lineWidth: isSelected ? 2 : 1)
        }
    }
}

#Preview("Maps Flow") {
    RecommendationView(
        data: RecommendationData(
            vibeName: "Vibrant & Spicy",
            vibeDescription: "Your playlist radiates bold energy.",
            mainMeal: Meal(
                title: "Ayam Panggang",
                price: "Rp 25.000",
                location: "Warung Nikmat",
                calories: "573 kcal",
                description: "A bold grilled chicken matching your playlist's energy.",
                realRestaurantName: "Warung Nikmat",
                latitude: -6.9175,
                longitude: 107.6191,
                distanceInMeters: 350
            ),
            alternatives: [
                Meal(
                    title: "Nasi Goreng",
                    price: "Rp 20.000",
                    location: "Warung Nikmat",
                    calories: "620 kcal",
                    description: "A warm fried rice to match the vibe."
                )
            ],
            restaurants: [
                RestaurantDishes(
                    restaurant: NearbyRestaurant(
                        name: "Warung Nikmat",
                        address: "Jl. Raya Bandung",
                        coordinate: .init(latitude: -6.9175, longitude: 107.6191),
                        distanceInMeters: 350
                    ),
                    dishes: [
                        Meal(title: "Ayam Panggang", price: "Rp 25.000", location: "Warung Nikmat", calories: "573 kcal", description: "Bold grilled chicken."),
                        Meal(title: "Sate Ayam", price: "Rp 20.000", location: "Warung Nikmat", calories: "450 kcal", description: "Classic chicken satay.")
                    ]
                )
            ],
            isMapsFlow: true
        ),
        onSelectMeal: { _ in }
    )
}

#Preview("Legacy Flow") {
    RecommendationView(
        data: RecommendationData(
            vibeName: "Chill Vibes",
            vibeDescription: "Relaxing playlist.",
            mainMeal: Meal(
                title: "Mie Ayam",
                price: "Rp 15.000",
                location: "Kantin UoB",
                calories: "540 cal",
                description: "Springy noodles for a light lunch."
            ),
            alternatives: [
                Meal(title: "Nasi Goreng", price: "Rp 18.000", location: "Kantin UoB", calories: "620 cal", description: "Warm fried rice.")
            ],
            isMapsFlow: false
        ),
        onSelectMeal: { _ in }
    )
}
