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
            VStack(spacing: 24) {
                // Header Brand Title
                brandHeaderView
                    .padding(.top, 12)
                
                if !viewModel.choseNay {
                    // Single option recommendation layout
                    mainCard(for: viewModel.mainMeal)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .leading)),
                            removal: .opacity.combined(with: .move(edge: .leading))
                        ))
                    
                    // Call to Action buttons
                    mainActionButtons
                        .padding(.horizontal, 24)
                } else {
                    // Multiple choices / Alternatives layout
                    alternativesSelectionView
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity.combined(with: .move(edge: .trailing))
                        ))
                }
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                closeButton
            }
        }
        .navigationDestination(isPresented: $viewModel.navigateToEnding) {
            if let meal = viewModel.finalMeal {
                EndingView(selectedMeal: meal)
            }
        }
    }
    
    // MARK: - Extracted UI Views
    
    private var brandHeaderView: some View {
        VStack(spacing: 4) {
            Text("Apple Intelligence Match")
                .font(.footnote)
                .foregroundStyle(.pink.gradient)
                .textCase(.uppercase)
                .tracking(1.5)
                .bold()
            
            Text("Your Best Lunch Match")
                .font(.title2.bold())
                .foregroundStyle(.primary)
        }
    }
    
    private var mainActionButtons: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.selectMainMeal()
            } label: {
                Label("Yay! Let's Eat!", systemImage: "fork.knife")
                    .font(.headline)
                    .bold()
                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(.pink)
            .controlSize(.large)
            .clipShape(Capsule())
            
            Button {
                viewModel.toggleShowAlternatives(show: true)
            } label: {
                Text("Nay, show me alternatives")
                    .font(.subheadline.bold())
                    .foregroundStyle(.pink)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.plain)
        }
    }
    
    private var alternativesSelectionView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Explore 2 Alternatives:")
                .font(.headline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
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
            .padding(.horizontal)
            
            if let selectedAlternative = viewModel.selectedAlternative {
                alternativeDescriptionBox(for: selectedAlternative)
            }
            
            Spacer()
            
            alternativeActionButtons
                .padding(.horizontal, 24)
        }
    }
    
    private func alternativeDescriptionBox(for meal: Meal) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Vibe & Details")
                .font(.subheadline.bold())
                .foregroundStyle(.pink)
            
            Text(meal.description)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
        .padding(.horizontal)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
    
    private var alternativeActionButtons: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.selectAlternativeMeal()
            } label: {
                Text("Let's Eat!")
                    .font(.headline)
                    .bold()
                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(.pink)
            .controlSize(.large)
            .disabled(viewModel.selectedAlternative == nil)
            .clipShape(Capsule())
            
            Button {
                viewModel.resetToMainSelection()
            } label: {
                Text("Show Best Match Again")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
            .padding(.top, 4)
        }
    }
    
    private var closeButton: some View {
        Button {
            dismiss()
            NotificationCenter.default.post(name: NSNotification.Name("ResetHome"), object: nil)
        } label: {
            Image(systemName: "xmark")
                .font(.body.bold())
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Extracted Card Components
    
    @ViewBuilder
    private func mainCard(for meal: Meal) -> some View {
        VStack(spacing: 0) {
            FoodImageView(
                mealTitle: meal.title,
                wikipediaQuery: meal.wikipediaSearchQuery,
                fallbackUrl: meal.imageUrl
            )
            .frame(width: 240, height: 240)
            .clipShape(Circle())
            .shadow(color: .black.opacity(0.15), radius: 10, y: 6)
            .padding(.top, 20)
            
            VStack(spacing: 16) {
                VStack(spacing: 6) {
                    Text(meal.title)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                    
                    Text(meal.location)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 16)
                
                HStack(spacing: 12) {
                    chip(label: meal.price, systemImage: "tag.fill")
                    chip(label: meal.calories, systemImage: "flame.fill")
                }
                
                Divider()
                    .padding(.horizontal)
                
                Text(meal.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineSpacing(4)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 24)
            }
        }
        .frame(maxWidth: .infinity)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.04), radius: 12, y: 6)
        .padding(.horizontal, 24)
    }
    
    @ViewBuilder
    private func alternativeCard(for meal: Meal, isSelected: Bool) -> some View {
        VStack(spacing: 12) {
            FoodImageView(
                mealTitle: meal.title,
                wikipediaQuery: meal.wikipediaSearchQuery,
                fallbackUrl: meal.imageUrl
            )
            .frame(width: 70, height: 70)
            .clipShape(Circle())
            .overlay(Circle().stroke(isSelected ? Color.pink : Color.clear, lineWidth: 2))
            .shadow(color: isSelected ? .pink.opacity(0.2) : .black.opacity(0.05), radius: 6, y: 3)
            
            VStack(spacing: 4) {
                Text(meal.title)
                    .font(.caption.bold())
                    .foregroundStyle(isSelected ? .pink : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 32)
                
                Text(meal.price)
                    .font(.caption2)
                    .bold()
                    .foregroundStyle(.pink)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(isSelected ? Color.pink.opacity(0.05) : Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isSelected ? Color.pink : Color.clear, lineWidth: 2)
        )
        .shadow(color: isSelected ? .pink.opacity(0.08) : .black.opacity(0.04), radius: 6, y: 3)
    }
    
    @ViewBuilder
    private func chip(label: String, systemImage: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.footnote)
                .foregroundStyle(.pink)
            Text(label)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.quaternary.opacity(0.4), in: Capsule())
    }
}

#Preview {
    RecommendationView(
        vibeName: "Vibrant & Spicy",
        mainMeal: Meal(
            title: "Nasi Uduk Ayam Goreng",
            price: "Rp 25.000",
            location: "Nasi Uduk Ibu Sum (0.4 km)",
            calories: "680 kcal",
            description: "Nasi uduk gurih wangi pandan disajikan hangat pakai ayam goreng kuning renyah, tempe garing, lalapan segar, plus sambal terasi ulek yang pedasnya mantap!",
            crazyFunDescription: "Warning — this meal may trigger spontaneous shoulder dancing.",
            systemImage: "flame.fill",
            gradientColors: ["orange", "red"]
        ),
        alternatives: []
    )
}

