import SwiftUI

public struct CardStyle: ViewModifier {
    public let cornerRadius: CornerRadius

    public init(cornerRadius: CornerRadius = .large) {
        self.cornerRadius = cornerRadius
    }

    public func body(content: Content) -> some View {
        content
            .padding()
            .background(.background, in: cornerRadius.roundedRect())
            .shadow(color: .black.opacity(0.07), radius: 14, y: 8)
    }
}

public struct CardStyleGroup: ViewModifier {
    public let cornerRadius: CornerRadius

    public init(cornerRadius: CornerRadius = .cardLarge) {
        self.cornerRadius = cornerRadius
    }

    public func body(content: Content) -> some View {
        content
            .padding(18)
            .padding(.bottom, 24)
            .background(.background, in: cornerRadius.roundedRect())
            .shadow(color: .black.opacity(0.05), radius: 18, y: 10)
    }
}

public extension View {
    func cardStyle(cornerRadius: CornerRadius = .large) -> some View {
        modifier(CardStyle(cornerRadius: cornerRadius))
    }

    func cardStyleGroup(cornerRadius: CornerRadius = .cardLarge) -> some View {
        modifier(CardStyleGroup(cornerRadius: cornerRadius))
    }
}
