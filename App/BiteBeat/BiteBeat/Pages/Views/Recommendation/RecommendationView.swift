import BiteBeatMusic
import SwiftUI

struct RecommendationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: RecommendationViewModel

    init(vibeName: String, mainMeal: Meal, alternatives: [Meal]) {
        _viewModel = State(initialValue: RecommendationViewModel(
            vibeName: vibeName,
            mainMeal: mainMeal,
            alternatives: alternatives
        ))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if !viewModel.choseNay {
                    mainRecommendationView
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .leading)),
                            removal: .opacity.combined(with: .move(edge: .leading))
                        ))
                } else {
                    alternativesSelectionView
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity.combined(with: .move(edge: .trailing))
                        ))
                }
            }
            .padding(.horizontal, 36)
            .padding(.top, 118)
            .padding(.bottom, 36)
        }
        .background(Color(uiColor: .systemBackground))
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(isPresented: $viewModel.navigateToEnding) {
            if let meal = viewModel.finalMeal {
                EndingView(selectedMeal: meal)
            }
        }
    }

    private var mainRecommendationView: some View {
        VStack(spacing: 0) {
            Text("Your Best Lunch Match")
                .font(.system(size: 21, weight: .bold, design: .rounded))
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .padding(.bottom, 34)

            mealHeroImage(for: viewModel.mainMeal, size: 264)

            mealSummary(for: viewModel.mainMeal)
                .padding(.top, 42)

            mainActionButtons
                .padding(.top, 44)
        }
    }

    private func mealSummary(for meal: Meal) -> some View {
        VStack(spacing: 18) {
            Text(meal.title)
                .font(.system(size: 29, weight: .bold, design: .rounded))
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.78)

            HStack(spacing: 18) {
                infoItem(systemImage: "creditcard", text: meal.price)
                infoItem(systemImage: "map", text: meal.restaurantName)
                infoItem(systemImage: "list.clipboard", text: meal.calories)
            }
            .frame(maxWidth: .infinity)

            Text(meal.description)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .foregroundStyle(Color(uiColor: .systemGray))
                .lineSpacing(3)
                .multilineTextAlignment(.center)
                .lineLimit(4)
                .minimumScaleFactor(0.88)
        }
    }

    private var mainActionButtons: some View {
        VStack(spacing: 10) {
            Button {
                viewModel.selectMainMeal()
            } label: {
                Text("Yay !")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.pink, in: Capsule())
            }
            .buttonStyle(.plain)
            .shadow(color: .pink.opacity(0.22), radius: 16, y: 8)

            Button {
                viewModel.toggleShowAlternatives(show: true)
            } label: {
                Text("Nay !")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.pink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(.white, in: Capsule())
                    .overlay {
                        Capsule()
                            .stroke(.pink, lineWidth: 1.5)
                    }
            }
            .buttonStyle(.plain)
        }
    }

    private var alternativesSelectionView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Pick Another Match")
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                    .foregroundStyle(.black)

                Text("Choose one meal that fits your mood better.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

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

            alternativeActionButtons
                .padding(.top, 8)
        }
    }

    private var alternativeActionButtons: some View {
        VStack(spacing: 10) {
            Button {
                viewModel.selectAlternativeMeal()
            } label: {
                Text("Yay !")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(viewModel.selectedAlternative == nil ? Color.gray.opacity(0.35) : Color.pink, in: Capsule())
            }
            .buttonStyle(.plain)
            .disabled(viewModel.selectedAlternative == nil)

            Button {
                viewModel.resetToMainSelection()
            } label: {
                Text("Back to Best Match")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.pink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(.white, in: Capsule())
                    .overlay {
                        Capsule()
                            .stroke(.pink, lineWidth: 1.5)
                    }
            }
            .buttonStyle(.plain)
        }
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
            mealHeroImage(for: meal, size: 88)

            Text(meal.title)
                .font(.caption.bold())
                .foregroundStyle(isSelected ? .pink : .black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 34)

            Text(meal.price)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(.white, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(isSelected ? Color.pink : Color(uiColor: .systemGray5), lineWidth: isSelected ? 2 : 1)
        }
        .shadow(color: .black.opacity(0.06), radius: 12, y: 6)
    }

    private func mealHeroImage(for meal: Meal, size: CGFloat) -> some View {
        FoodImageView(
            directImageURL: meal.imageUrl,
            searchQuery: meal.photoSearchQuery,
            systemImage: meal.systemImage,
            gradientColors: meal.swiftUIColors
        )
        .frame(width: size, height: size)
        .clipShape(Circle())
        .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
    }

    private func infoItem(systemImage: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.pink)
                .frame(width: 20, height: 20)

            Text(text)
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundStyle(Color(uiColor: .systemGray))
                .lineLimit(1)
                .minimumScaleFactor(0.68)
        }
        .frame(minWidth: 0)
    }
}

#Preview {
    RecommendationView(
        vibeName: "Vibrant & Spicy",
        mainMeal: Meal(
            title: "Ayam Panggang",
            price: "17.000 IDR",
            location: "Kantin UoB",
            calories: "573 cal",
            description: "The mix of relaxing melodies and upbeat pop feels similar to enjoying a flavorful, satisfying meal that feels both cozy and energizing.",
            crazyFunDescription: "Warning - this meal may trigger spontaneous shoulder dancing.",
            systemImage: "flame.fill",
            gradientColors: ["orange", "red"]
        ),
        alternatives: [
            Meal(
                title: "Nasi Goreng",
                price: "18.000 IDR",
                location: "Kantin UoB",
                calories: "620 cal",
                description: "A warm, familiar plate with enough rhythm and comfort to match your playlist.",
                systemImage: "flame.fill",
                gradientColors: ["orange", "red"]
            ),
            Meal(
                title: "Mie Ayam",
                price: "15.000 IDR",
                location: "Kantin UoB",
                calories: "540 cal",
                description: "Springy noodles and savory broth for a light but satisfying lunch mood.",
                systemImage: "leaf.fill",
                gradientColors: ["green", "teal"]
            )
        ]
    )
}

