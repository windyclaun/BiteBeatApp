import SwiftUI

struct RotatingStarburst: View {
    let size: CGSize
    let center: CGPoint
    let isAnimating: Bool

    var body: some View {
        Starburst(size: size, center: center)
            .rotationEffect(
                .degrees(isAnimating ? 360 : 0),
                anchor: UnitPoint(x: center.x / size.width, y: center.y / size.height)
            )
            .animation(
                isAnimating ? .linear(duration: 18).repeatForever(autoreverses: false) : nil,
                value: isAnimating
            )
    }
}
