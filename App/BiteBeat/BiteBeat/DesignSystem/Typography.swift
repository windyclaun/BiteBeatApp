import SwiftUI

public enum BiteBeatFont {
    case displayLarge
    case displayMedium
    case displaySmall
    case largeTitle
    case title
    case title2
    case title3
    case headline
    case body
    case callout
    case subheadline
    case footnote
    case caption
    case caption2

    fileprivate var textStyle: Font.TextStyle {
        switch self {
        case .displayLarge, .displayMedium: return .largeTitle
        case .displaySmall: return .title
        case .largeTitle: return .largeTitle
        case .title: return .title
        case .title2: return .title2
        case .title3: return .title3
        case .headline: return .headline
        case .body: return .body
        case .callout: return .callout
        case .subheadline: return .subheadline
        case .footnote: return .footnote
        case .caption: return .caption
        case .caption2: return .caption2
        }
    }

    fileprivate var defaultWeight: Font.Weight {
        switch self {
        case .displayLarge: return .bold
        case .displayMedium: return .semibold
        case .displaySmall: return .bold
        case .headline: return .bold
        default: return .regular
        }
    }
}

public extension View {
    func biteBeatFont(_ style: BiteBeatFont, weight: Font.Weight? = nil) -> some View {
        let w = weight ?? style.defaultWeight
        return font(.system(style.textStyle, design: .default).weight(w))
    }
}
