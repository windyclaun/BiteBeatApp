import BiteBeatMusic
import SwiftUI

struct RecommendationView: View {
    let vibe: MusicVibe
    let mainMeal: Meal
    let alternatives: [Meal]
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var choseNay = false
    @State private var selectedAlternative: Meal?
    @State private var navigateToEnding = false
    @State private var finalMeal: Meal?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text("Apple Intelligence Match")
                        .font(.footnote)
                        .foregroundStyle(.pink.gradient)
                        .textCase(.uppercase)
                        .tracking(1.5)
                        .bold()
                    
                    Text("Your Best Lunch Match")
                        .font(.title.bold())
                        .foregroundStyle(.primary)
                }
                .padding(.top, 12)
                
                if !choseNay {
                    mainCard(for: mainMeal)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .leading)),
                            removal: .opacity.combined(with: .move(edge: .leading))
                        ))
                    
                    HStack(spacing: 16) {
                        Button {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                                choseNay = true
                            }
                        } label: {
                            Label("Nay!", systemImage: "hand.thumbsdown.fill")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                        }
                        .buttonStyle(.bordered)
                        .tint(.secondary)
                        .controlSize(.large)
                        
                        Button {
                            finalMeal = mainMeal
                            navigateToEnding = true
                        } label: {
                            Label("Yay! Let's Eat!", systemImage: "fork.knife")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .bold()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.pink)
                        .controlSize(.large)
                    }
                    .padding(.horizontal)
                } else {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Explore 2 Alternatives:")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(alternatives) { meal in
                                Button {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                                        selectedAlternative = meal
                                    }
                                } label: {
                                    alternativeCard(for: meal, isSelected: selectedAlternative?.id == meal.id)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        
                        if let selectedAlternative {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Vibe & Details")
                                    .font(.subheadline.bold())
                                    .foregroundStyle(.pink)
                                
                                Text(selectedAlternative.description)
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
                        
                        Spacer()
                        
                        Button {
                            if let selectedAlternative {
                                finalMeal = selectedAlternative
                                navigateToEnding = true
                            }
                        } label: {
                            Text("Let's Eat!")
                                .font(.headline)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.pink)
                        .disabled(selectedAlternative == nil)
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        Button {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                                choseNay = false
                                selectedAlternative = nil
                            }
                        } label: {
                            Text("Show Best Match Again")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.top, 4)
                    }
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .trailing)),
                        removal: .opacity.combined(with: .move(edge: .trailing))
                    ))
                }
            }
            .padding(.bottom, 32)
            .navigationDestination(isPresented: $navigateToEnding) {
                if let meal = finalMeal {
                    EndingView(selectedMeal: meal)
                }
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Exit") {
                    dismiss()
                }
                .foregroundStyle(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private func mainCard(for meal: Meal) -> some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: meal.swiftUIColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 150, height: 150)
                    .blur(radius: 20)
                    .opacity(0.3)
                
                Circle()
                    .fill(LinearGradient(
                        colors: meal.swiftUIColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 120, height: 120)
                    .shadow(color: meal.swiftUIColors.first?.opacity(0.4) ?? .black.opacity(0.1), radius: 10, y: 5)
                
                Image(systemName: meal.systemImage)
                    .font(.system(size: 52))
                    .foregroundStyle(.white)
            }
            .padding(.top, 16)
            
            VStack(spacing: 8) {
                Text(meal.title)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                
                Text(meal.location)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
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
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.06), radius: 12, y: 6)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func alternativeCard(for meal: Meal, isSelected: Bool) -> some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: meal.swiftUIColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 60, height: 60)
                
                Image(systemName: meal.systemImage)
                    .font(.system(size: 24))
                    .foregroundStyle(.white)
            }
            
            VStack(spacing: 4) {
                Text(meal.title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 38)
                
                Text(meal.price)
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.pink)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(isSelected ? Color.pink.opacity(0.07) : Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(isSelected ? .pink : .clear, lineWidth: 2)
        }
        .shadow(color: isSelected ? .pink.opacity(0.1) : .black.opacity(0.04), radius: 6, y: 3)
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
        vibe: .vibrantSpicy,
        mainMeal: Meal(
            title: "Nasi Uduk Ayam Goreng",
            price: "Rp 25.000",
            location: "Nasi Uduk Ibu Sum (0.4 km)",
            calories: "680 kcal",
            description: "Nasi uduk gurih wangi pandan disajikan hangat pakai ayam goreng kuning renyah, tempe garing, lalapan segar, plus sambal terasi ulek yang pedasnya mantap!",
            systemImage: "flame.fill",
            gradientColors: ["orange", "red"]
        ),
        alternatives: []
    )
}
