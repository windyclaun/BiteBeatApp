import BiteBeatMusic
import SwiftUI

struct EndingView: View {
    @State private var viewModel: EndingViewModel
    
    init(selectedMeal: Meal) {
        _viewModel = State(initialValue: EndingViewModel(selectedMeal: selectedMeal))
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Pulsing Background Glow and Circular Food Artwork
            heroImageView
                .padding(.top, 16)
            
            // Decisive Brand Headers
            savedHeaderView
            
            // Saved Decision Details Card
            savedDecisionCard
            
            // Next-step steps List
            lunchQuestListView
            
            Spacer()
            
            // Return Navigation Button
            backToHomeButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationBarBackButtonHidden()
        .onAppear {
            viewModel.handleOnAppear()
        }
    }
    
    // MARK: - Extracted UI Views
    
    private var heroImageView: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(
                    colors: viewModel.selectedMeal.swiftUIColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 160, height: 160)
                .blur(radius: 20)
                .opacity(0.3)
            
            FoodImageView(
                mealTitle: viewModel.selectedMeal.title,
                wikipediaQuery: viewModel.selectedMeal.wikipediaSearchQuery,
                fallbackUrl: viewModel.selectedMeal.imageUrl
            )
            .frame(width: 130, height: 130)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: viewModel.selectedMeal.swiftUIColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
            )
            .shadow(
                color: viewModel.selectedMeal.swiftUIColors.first?.opacity(0.3) ?? .black.opacity(0.1),
                radius: 10,
                y: 5
            )
        }
    }
    
    private var savedHeaderView: some View {
        VStack(spacing: 8) {
            Text("Decision Saved!")
                .font(.title2.bold())
                .foregroundStyle(.primary)
            
            Text(viewModel.enjoymentGreeting)
                .font(.largeTitle.bold())
                .foregroundStyle(.pink.gradient)
        }
    }
    
    private var savedDecisionCard: some View {
        VStack(spacing: 12) {
            Text(viewModel.selectedMeal.title)
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text("📍 " + viewModel.selectedMeal.location)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 16) {
                Label(viewModel.selectedMeal.price, systemImage: "tag.fill")
                Label(viewModel.selectedMeal.calories, systemImage: "flame.fill")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.background, in: RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
        .padding(.horizontal, 24)
    }
    
    private var lunchQuestListView: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Your Lunch Quest:")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
            
            VStack(spacing: 10) {
                stepRow(
                    number: "1",
                    text: "Put on your shoes and walk to \(viewModel.selectedMeal.restaurantName).",
                    icon: "figure.walk"
                )
                
                stepRow(
                    number: "2",
                    text: "Plug in your headphones & enjoy your beats.",
                    icon: "headphones"
                )
                
                stepRow(
                    number: "3",
                    text: "Sit down, order your meal, and dig in!",
                    icon: "mouth.fill"
                )
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var backToHomeButton: some View {
        Button {
            NotificationCenter.default.post(name: NSNotification.Name("ResetHome"), object: nil)
        } label: {
            Text("Back to Home")
                .font(.headline)
                .bold()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .tint(.pink)
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
    
    @ViewBuilder
    private func stepRow(number: String, text: String, icon: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.quaternary)
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(.pink)
            }
            
            Text(text)
                .font(.footnote)
                .foregroundStyle(.primary)
                .lineLimit(2)
            
            Spacer()
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.02), radius: 4, y: 2)
    }
}

#Preview {
    EndingView(selectedMeal: Meal(
        title: "Nasi Uduk Ayam Goreng",
        price: "Rp 25.000",
        location: "Nasi Uduk Ibu Sum (0.4 km)",
        calories: "680 kcal",
        description: "Nasi uduk gurih wangi pandan disajikan hangat pakai ayam goreng kuning renyah, tempe garing, lalapan segar, plus sambal terasi ulek yang pedasnya mantap!",
        systemImage: "flame.fill",
        gradientColors: ["orange", "red"]
    ))
}
