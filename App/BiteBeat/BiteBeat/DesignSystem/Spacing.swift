import SwiftUI

public enum Spacing: CGFloat, CaseIterable {
    case xs = 4
    case sm = 8
    case md = 12
    case lg = 16
    case xl = 20
    case xxl = 24
    case xxxl = 32
    case huge = 48
}

public enum ScreenPadding {
    public static let horizontal: CGFloat = Spacing.xxl.rawValue
}

public extension View {
    func screenPadding() -> some View {
        padding(.horizontal, ScreenPadding.horizontal)
    }

    func padding(_ spacing: Spacing) -> some View {
        padding(spacing.rawValue)
    }

    func padding(_ edges: Edge.Set, _ spacing: Spacing) -> some View {
        padding(edges, spacing.rawValue)
    }
}
