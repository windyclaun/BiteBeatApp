import BiteBeatMusic
import SwiftUI

struct EndingView: View {
    @State private var viewModel: EndingViewModel

    init(selectedMeal: Meal) {
        _viewModel = State(initialValue: EndingViewModel(selectedMeal: selectedMeal))
    }

    var body: some View {
        ZStack {
            EndingGradientBackground()
                .ignoresSafeArea()

            EndingContentView(
                meal: viewModel.selectedMeal,
                greeting: viewModel.enjoymentGreeting
            )
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            viewModel.handleOnAppear()
        }
        .onDisappear {
            viewModel.handleOnDisappear()
        }
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
