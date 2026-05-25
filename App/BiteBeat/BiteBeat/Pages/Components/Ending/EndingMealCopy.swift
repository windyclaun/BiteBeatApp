import BiteBeatMusic
import SwiftUI

struct EndingMealCopy: View {
    @State private var isShowingDetails = false

    let meal: Meal

    var body: some View {
        VStack(spacing: 16) {
            Text(meal.title)
                .font(.system(size: 29, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.78)

            VStack(spacing: 8) {
                Text(meal.crazyFunDescription)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .lineLimit(2)

                Button {
                    isShowingDetails = true
                } label: {
                    Text("See more")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.16), in: Capsule())
                        .overlay {
                            Capsule()
                                .stroke(.white.opacity(0.22), lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 36)
        .sheet(isPresented: $isShowingDetails) {
            EndingMealDetailSheet(meal: meal)
        }
    }
}
