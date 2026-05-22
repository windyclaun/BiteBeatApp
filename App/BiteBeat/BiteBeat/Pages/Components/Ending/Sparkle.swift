import SwiftUI

struct Sparkle: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let longRadius = min(rect.width, rect.height) / 2
        let shortRadius = longRadius * 0.16

        var path = Path()
        path.move(to: CGPoint(x: center.x, y: center.y - longRadius))
        path.addQuadCurve(
            to: CGPoint(x: center.x + shortRadius, y: center.y - shortRadius),
            control: CGPoint(x: center.x + shortRadius * 0.55, y: center.y - shortRadius * 0.55)
        )
        path.addQuadCurve(
            to: CGPoint(x: center.x + longRadius, y: center.y),
            control: CGPoint(x: center.x + shortRadius * 0.55, y: center.y - shortRadius * 0.55)
        )
        path.addQuadCurve(
            to: CGPoint(x: center.x + shortRadius, y: center.y + shortRadius),
            control: CGPoint(x: center.x + shortRadius * 0.55, y: center.y + shortRadius * 0.55)
        )
        path.addQuadCurve(
            to: CGPoint(x: center.x, y: center.y + longRadius),
            control: CGPoint(x: center.x + shortRadius * 0.55, y: center.y + shortRadius * 0.55)
        )
        path.addQuadCurve(
            to: CGPoint(x: center.x - shortRadius, y: center.y + shortRadius),
            control: CGPoint(x: center.x - shortRadius * 0.55, y: center.y + shortRadius * 0.55)
        )
        path.addQuadCurve(
            to: CGPoint(x: center.x - longRadius, y: center.y),
            control: CGPoint(x: center.x - shortRadius * 0.55, y: center.y + shortRadius * 0.55)
        )
        path.addQuadCurve(
            to: CGPoint(x: center.x - shortRadius, y: center.y - shortRadius),
            control: CGPoint(x: center.x - shortRadius * 0.55, y: center.y - shortRadius * 0.55)
        )
        path.addQuadCurve(
            to: CGPoint(x: center.x, y: center.y - longRadius),
            control: CGPoint(x: center.x - shortRadius * 0.55, y: center.y - shortRadius * 0.55)
        )
        path.closeSubpath()
        return path
    }
}
