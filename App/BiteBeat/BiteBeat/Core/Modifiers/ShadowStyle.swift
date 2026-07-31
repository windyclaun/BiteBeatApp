import SwiftUI

public struct ShadowStyle: ViewModifier {
    public let radius: CGFloat
    public let y: CGFloat
    public let opacity: Double

    public init(radius: CGFloat = 10, y: CGFloat = 5, opacity: Double = 0.08) {
        self.radius = radius
        self.y = y
        self.opacity = opacity
    }

    public func body(content: Content) -> some View {
        content.shadow(color: .black.opacity(opacity), radius: radius, y: y)
    }
}

public extension View {
    func shadowStyle(radius: CGFloat = 10, y: CGFloat = 5, opacity: Double = 0.08) -> some View {
        modifier(ShadowStyle(radius: radius, y: y, opacity: opacity))
    }
}
