import BiteBeatMusic
import SwiftUI

struct RecommendationView: View {
    let vibeName: String
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
                // Header Brand
                VStack(spacing: 4) {
                    Text("Apple Intelligence Match")
                        .font(.footnote)
                        .foregroundStyle(.pink.gradient)
                        .textCase(.uppercase)
                        .tracking(1.5)
                        .bold()
                    
                    Text("Your Best Lunch Match")
                        .font(.title2.bold()) // Disesuaikan agar lebih rapi di screen kecil
                        .foregroundStyle(.primary)
                }
                .padding(.top, 12)
                
                if !choseNay {
                    // Tampilan Utama (Sesuai dengan screen "Single Option" di Figma)
                    mainCard(for: mainMeal)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .leading)),
                            removal: .opacity.combined(with: .move(edge: .leading))
                        ))
                    
                    // Tombol Aksi - Diubah menjadi VStack agar sesuai dengan layout bertumpuk di Figma
                    VStack(spacing: 12) {
                        Button {
                            finalMeal = mainMeal
                            navigateToEnding = true
                        } label: {
                            Label("Yay! Let's Eat!", systemImage: "fork.knife")
                                .font(.headline)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.pink)
                        .controlSize(.large)
                        .clipShape(Capsule()) // Mengikuti lekukan tombol elips di desain
                        
                        Button {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
                                choseNay = true
                            }
                        } label: {
                            Text("Nay, show me alternatives")
                                .font(.subheadline.bold())
                                .foregroundStyle(.pink)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 24)
                    
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
                        
                        VStack(spacing: 12) {
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
                            .clipShape(Capsule())
                            
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
                        .padding(.horizontal, 24)
                    }
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
                Button {
                    NotificationCenter.default.post(name: NSNotification.Name("ResetHome"), object: nil)
                } label: {
                    Image(systemName: "xmark")
                        .font(.body.bold())
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationDestination(isPresented: $navigateToEnding) {
            if let meal = finalMeal {
                EndingView(selectedMeal: meal)
            }
        }
    }
    
    @ViewBuilder
    private func mainCard(for meal: Meal) -> some View {
        VStack(spacing: 0) {
            // DIUBAH: Mengikuti gambar bulat besar (makanan melingkar) di tengah design Figma
            FoodImageView(
                mealTitle: meal.title,
                wikipediaQuery: meal.wikipediaSearchQuery,
                fallbackUrl: meal.imageUrl
            )
            .frame(width: 240, height: 240) // Ukuran proporsional bulat di Figma
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
            systemImage: "flame.fill",
            gradientColors: ["orange", "red"]
        ),
        alternatives: []
    )
}
