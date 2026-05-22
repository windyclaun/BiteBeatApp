import SwiftUI

struct EndingGradientBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animateEffects = false

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let center = CGPoint(x: size.width * 0.5, y: size.height * 0.46)

            ZStack {
                backgroundGradient(in: size)
                RotatingStarburst(size: size, center: center, isAnimating: animateEffects && !reduceMotion)
                sparkleLayer(in: size)
            }
            .onAppear {
                guard !reduceMotion else { return }
                animateEffects = true
            }
        }
    }

    private func backgroundGradient(in size: CGSize) -> some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.80, green: 0.03, blue: 0.16),
                    Color(red: 0.93, green: 0.07, blue: 0.23),
                    Color(red: 0.99, green: 0.10, blue: 0.28)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [.white.opacity(0.28), .clear],
                center: .top,
                startRadius: 12,
                endRadius: size.height * 0.58
            )
        }
    }

    private func sparkleLayer(in size: CGSize) -> some View {
        ZStack {
            BlinkingSparkle(
                size: 30,
                baseOpacity: 0.95,
                position: CGPoint(x: size.width * 0.19, y: size.height * 0.55),
                delay: 0,
                isAnimating: animateEffects && !reduceMotion
            )

            BlinkingSparkle(
                size: 18,
                baseOpacity: 0.5,
                position: CGPoint(x: size.width * 0.13, y: size.height * 0.58),
                delay: 0.45,
                isAnimating: animateEffects && !reduceMotion
            )

            BlinkingSparkle(
                size: 20,
                baseOpacity: 0.95,
                position: CGPoint(x: size.width * 0.82, y: size.height * 0.30),
                delay: 0.25,
                isAnimating: animateEffects && !reduceMotion
            )

            BlinkingSparkle(
                size: 28,
                baseOpacity: 0.26,
                position: CGPoint(x: size.width * 0.77, y: size.height * 0.27),
                delay: 0.7,
                isAnimating: animateEffects && !reduceMotion
            )
        }
    }
}
