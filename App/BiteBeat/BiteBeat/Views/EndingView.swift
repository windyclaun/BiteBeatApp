import BiteBeatMusic
import SwiftUI

struct EndingView: View {
    let selectedMeal: Meal
    
    @Environment(\.dismiss) private var dismiss
    @State private var animateSteps = false
    @State private var enjoymentGreeting = "Selamat Makan! 🇮🇩"
    
    private let greetings = [
        "Selamat Makan! 🇮🇩",
        "Bon Appétit! 🇫🇷",
        "Itadakimasu! 🇯🇵",
        "Buon Appetito! 🇮🇹",
        "¡Buen Provecho! 🇪🇸",
        "Guten Appetit! 🇩🇪",
        "Enjoy Your Meal! 🇬🇧",
        "Mas-issge Deuseyo! 🇰🇷",
        "Bom Apetite! 🇵🇹",
        "Afiyet Olsun! 🇹🇷"
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: selectedMeal.swiftUIColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 160, height: 160)
                    .blur(radius: 20)
                    .opacity(0.3)
                
                FoodImageView(
                    mealTitle: selectedMeal.title,
                    wikipediaQuery: selectedMeal.wikipediaSearchQuery,
                    fallbackUrl: selectedMeal.imageUrl
                )
                .frame(width: 130, height: 130)
                .clipShape(Circle())
                .overlay(Circle().stroke(LinearGradient(colors: selectedMeal.swiftUIColors, startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 3))
                .shadow(color: selectedMeal.swiftUIColors.first?.opacity(0.3) ?? .black.opacity(0.1), radius: 10, y: 5)
            }
            .padding(.top, 16)
            
            VStack(spacing: 8) {
                Text("Decision Saved!")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                
                Text(enjoymentGreeting)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.pink.gradient)
            }
            
            VStack(spacing: 12) {
                Text(selectedMeal.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text("📍 " + selectedMeal.location)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 16) {
                    Label(selectedMeal.price, systemImage: "tag.fill")
                    Label(selectedMeal.calories, systemImage: "flame.fill")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.background, in: RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
            .padding(.horizontal, 24)
            
            VStack(alignment: .leading, spacing: 14) {
                Text("Your Lunch Quest:")
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                
                VStack(spacing: 10) {
                    stepRow(number: "1", text: "Put on your shoes and walk to \(selectedMeal.restaurantName).", icon: "figure.walk")
                    
                    stepRow(number: "2", text: "Plug in your headphones & enjoy your beats.", icon: "headphones")
                    
                    stepRow(number: "3", text: "Sit down, order your meal, and dig in!", icon: "mouth.fill")
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationBarBackButtonHidden()
        .onAppear {
            if let randomGreeting = greetings.randomElement() {
                enjoymentGreeting = randomGreeting
            }
        }
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
