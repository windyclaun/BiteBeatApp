import SwiftUI

public enum BiteBeatFont {
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
    case custom(CGFloat)

    fileprivate var textStyle: Font.TextStyle? {
        switch self {
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
        case .custom: return nil
        }
    }
}

public extension View {
    func biteBeatFont(_ style: BiteBeatFont, weight: Font.Weight = .regular) -> some View {
        switch style {
        case .custom(let size):
            return font(.system(size: size, weight: weight, design: .default))
        default:
            guard let textStyle = style.textStyle else {
                return font(.system(.body, design: .default).weight(weight))
            }
            return font(.system(textStyle, design: .default).weight(weight))
        }
    }
}
