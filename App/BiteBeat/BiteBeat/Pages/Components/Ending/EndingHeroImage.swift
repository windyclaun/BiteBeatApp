import BiteBeatMusic
import SwiftUI

struct EndingHeroImage: View {
    let meal: Meal

    var body: some View {
        GeometryReader { proxy in
            let imageSize = min(proxy.size.width * 0.72, 270)

            ZStack {
                EndingCircleLight(imageSize: imageSize)

                FoodImageView(
                    mealTitle: meal.title,
                    wikipediaQuery: meal.wikipediaSearchQuery,
                    fallbackUrl: meal.imageUrl
                )
                .frame(width: imageSize, height: imageSize)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(.white.opacity(0.78), lineWidth: 2)
                }
                .shadow(color: .black.opacity(0.22), radius: 14, y: 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 270)
    }
}
