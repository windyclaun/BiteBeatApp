import SwiftUI

struct EndingMealCopy: View {
    let mealTitle: String

    var body: some View {
        VStack(spacing: 20) {
            Text(mealTitle)
                .font(.system(size: 29, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.78)

            Text("Warning - this meal may trigger\nspontaneous shoulder dancing.")
                .font(.system(size: 17, weight: .regular, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .padding(.horizontal, 36)
    }
}
