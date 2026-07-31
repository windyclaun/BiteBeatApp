import SwiftUI

public enum CornerRadius: CGFloat {
    case small = 8
    case medium = 12
    case large = 16
    case xl = 20
    case cardLarge = 32

    public func roundedRect(style: RoundedCornerStyle = .continuous) -> RoundedRectangle {
        RoundedRectangle(cornerRadius: rawValue, style: style)
    }
}
