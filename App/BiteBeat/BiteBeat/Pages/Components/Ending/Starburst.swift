import SwiftUI

struct Starburst: View {
    let size: CGSize
    let center: CGPoint

    private var rayLength: CGFloat {
        hypot(size.width, size.height)
    }

    var body: some View {
        ZStack {
            BurstRay(
                center: center,
                first: point(angle: 188, length: rayLength),
                second: point(angle: 216, length: rayLength),
                opacity: 0.34
            )

            BurstRay(
                center: center,
                first: point(angle: 146, length: rayLength),
                second: point(angle: 172, length: rayLength),
                opacity: 0.22
            )

            BurstRay(
                center: center,
                first: point(angle: 332, length: rayLength),
                second: point(angle: 358, length: rayLength),
                opacity: 0.26
            )

            BurstRay(
                center: center,
                first: point(angle: 18, length: rayLength),
                second: point(angle: 46, length: rayLength),
                opacity: 0.18
            )

            BurstRay(
                center: center,
                first: point(angle: 56, length: rayLength),
                second: point(angle: 72, length: rayLength),
                opacity: 0.12
            )

            BurstRay(
                center: center,
                first: point(angle: 248, length: rayLength),
                second: point(angle: 268, length: rayLength),
                opacity: 0.14
            )
        }
        .frame(width: size.width, height: size.height)
    }

    private func point(angle degrees: Double, length: CGFloat) -> CGPoint {
        let radians = degrees * .pi / 180
        return CGPoint(
            x: center.x + cos(radians) * length,
            y: center.y + sin(radians) * length
        )
    }
}
