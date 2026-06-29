import BiteBeatMusic
import SwiftUI

struct EndingMealCopy: View {
    @State private var isShowingDetails = false
    let meal: Meal

    var body: some View {
        VStack(spacing: 16) {
            Text(meal.title)
                .biteBeatFont(.title, weight: .bold)
                .foregroundStyle(Color.onAccent)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.78)

            VStack(spacing: 8) {
                Text(meal.crazyFunDescription)
                    .biteBeatFont(.body)
                    .foregroundStyle(Color.onAccent)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .lineLimit(2)

                Button {
                    isShowingDetails = true
                } label: {
                    Text("See more")
                        .biteBeatFont(.subheadline, weight: .semibold)
                        .foregroundStyle(Color.onAccent)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.glass)
            }
        }
        .padding(.horizontal, 36)
        .sheet(isPresented: $isShowingDetails) {
            EndingMealDetailSheet(meal: meal)
        }
    }
}
