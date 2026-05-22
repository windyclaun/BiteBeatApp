import SwiftUI

struct RotatingStarburst: View {
    let size: CGSize
    let center: CGPoint
    let isAnimating: Bool

    var body: some View {
        ZStack {
            rotatingLayer(direction: .clockwise, degrees: isAnimating ? 360 : 0, duration: 18)
            rotatingLayer(direction: .counterclockwise, degrees: isAnimating ? -360 : 0, duration: 22)
        }
        .frame(width: size.width, height: size.height)
    }

    private func rotatingLayer(direction: Starburst.Direction, degrees: Double, duration: Double) -> some View {
        Starburst(size: size, center: center, direction: direction)
            .frame(width: size.width, height: size.height)
            .rotationEffect(
                .degrees(degrees),
                anchor: UnitPoint(x: center.x / size.width, y: center.y / size.height)
            )
            .animation(
                isAnimating ? .linear(duration: duration).repeatForever(autoreverses: false) : nil,
                value: isAnimating
            )
    }
}
