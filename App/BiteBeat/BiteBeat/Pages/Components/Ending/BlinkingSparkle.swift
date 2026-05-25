import SwiftUI

struct BlinkingSparkle: View {
    let size: CGFloat
    let baseOpacity: Double
    let position: CGPoint
    let delay: Double
    let isAnimating: Bool

    var body: some View {
        Sparkle()
            .fill(.white.opacity(isAnimating ? baseOpacity : baseOpacity * 0.3))
            .frame(width: size, height: size)
            .scaleEffect(isAnimating ? 1.18 : 0.72)
            .position(position)
            .animation(
                isAnimating ? .easeInOut(duration: 0.9).repeatForever(autoreverses: true).delay(delay) : nil,
                value: isAnimating
            )
    }
}
