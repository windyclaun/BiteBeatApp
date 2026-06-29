import SwiftUI

public extension Color {
    static let onAccent = Color(.white)

    static let groupedBackground = Color(.systemGroupedBackground)
    static let secondaryGroupedBackground = Color(.secondarySystemGroupedBackground)
    static let tertiaryGroupedBackground = Color(.tertiarySystemGroupedBackground)

    static let statusGreen = Color(.systemGreen)
    static let statusOrange = Color(.systemOrange)
    static let statusRed = Color(.systemRed)
}

public extension ShapeStyle where Self == Color {
    static var groupedBackground: Color { .groupedBackground }
    static var secondaryGroupedBackground: Color { .secondaryGroupedBackground }
    static var tertiaryGroupedBackground: Color { .tertiaryGroupedBackground }
    static var onAccent: Color { .onAccent }
    static var statusGreen: Color { .statusGreen }
    static var statusOrange: Color { .statusOrange }
    static var statusRed: Color { .statusRed }
}
