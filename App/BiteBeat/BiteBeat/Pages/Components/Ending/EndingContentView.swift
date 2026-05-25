import BiteBeatMusic
import SwiftUI

struct EndingContentView: View {
    let meal: Meal
    let greeting: String


    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 106)

            EndingGreetingText(greeting: greeting)

            EndingHeroImage(meal: meal)
                .padding(.top, 38)

            EndingMealCopy(meal: meal)
                .padding(.top, 36)

            Spacer(minLength: 32)

            EndingActionButton()
                .padding(.horizontal, 38)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EndingView(selectedMeal: Meal(
        title: "Ayam Panggang",
        price: "Rp 25.000",
        location: "Nasi Uduk Ibu Sum (0.4 km)",
        calories: "680 kcal",
        description: "Nasi uduk gurih wangi pandan disajikan hangat pakai ayam goreng kuning renyah, tempe garing, lalapan segar, plus sambal terasi ulek yang pedasnya mantap!",
        crazyFunDescription: "Warning — this meal may trigger spontaneous shoulder dancing.",
        systemImage: "flame.fill",
        gradientColors: ["orange", "red"]
    ))
}
