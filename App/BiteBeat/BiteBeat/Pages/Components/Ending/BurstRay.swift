import SwiftUI

struct BurstRay: View {
    let center: CGPoint
    let first: CGPoint
    let second: CGPoint
    let opacity: Double

    var body: some View {
        Path { path in
            path.move(to: center)
            path.addLine(to: first)
            path.addLine(to: second)
            path.closeSubpath()
        }
        .fill(.white.opacity(opacity))
    }
}
