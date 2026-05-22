import SwiftUI

struct Starburst: View {
    enum Direction {
        case clockwise
        case counterclockwise
    }

    let size: CGSize
    let center: CGPoint
    let direction: Direction

    private var rayLength: CGFloat {
        hypot(size.width, size.height)
    }

    private var rays: [StarburstRay] {
        switch direction {
        case .clockwise:
            [
                StarburstRay(startAngle: 188, endAngle: 216, opacity: 0.34),
                StarburstRay(startAngle: 332, endAngle: 358, opacity: 0.26),
                StarburstRay(startAngle: 56, endAngle: 72, opacity: 0.12)
            ]
        case .counterclockwise:
            [
                StarburstRay(startAngle: 146, endAngle: 172, opacity: 0.22),
                StarburstRay(startAngle: 18, endAngle: 46, opacity: 0.18),
                StarburstRay(startAngle: 248, endAngle: 268, opacity: 0.14)
            ]
        }
    }

    var body: some View {
        ZStack {
            ForEach(rays) { ray in
                BurstRay(
                    center: center,
                    first: point(angle: ray.startAngle, length: rayLength),
                    second: point(angle: ray.endAngle, length: rayLength),
                    opacity: ray.opacity
                )
            }
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

private struct StarburstRay: Identifiable {
    let id = UUID()
    let startAngle: Double
    let endAngle: Double
    let opacity: Double
}
