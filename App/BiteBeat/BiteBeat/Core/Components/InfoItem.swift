import SwiftUI

public struct InfoItem: View {
    public let systemImage: String
    public let text: String

    public init(systemImage: String, text: String) {
        self.systemImage = systemImage
        self.text = text
    }

    public var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .biteBeatFont(.subheadline, weight: .semibold)
                .foregroundStyle(Color.accentColor)
                .frame(width: 20, height: 20)

            Text(text)
                .biteBeatFont(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.68)
        }
        .frame(minWidth: 0)
    }
}

#Preview {
    HStack {
        InfoItem(systemImage: "creditcard", text: "Rp 25.000")
        InfoItem(systemImage: "flame", text: "500 kcal")
    }
    .padding()
}
