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

            EndingMealCopy(mealTitle: meal.title)
                .padding(.top, 36)

            Spacer(minLength: 32)

            EndingActionButton()
                .padding(.horizontal, 38)
                .padding(.bottom, 42)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
