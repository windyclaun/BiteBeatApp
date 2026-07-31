import SwiftUI

public struct StatusBanner: View {
    public let icon: String
    public let title: String
    public let subtitle: String
    public let tintColor: Color

    public init(icon: String, title: String, subtitle: String, tintColor: Color = .statusRed) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.tintColor = tintColor
    }

    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .biteBeatFont(.title2, weight: .semibold)
                .foregroundStyle(tintColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(subtitle)
                    .biteBeatFont(.caption, weight: .light)
                    .foregroundStyle(tintColor)

                Text(title)
                    .biteBeatFont(.caption, weight: .bold)
                    .foregroundStyle(tintColor)
            }

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .glassEffect(.regular.tint(Color.accentColor), in: .capsule)
    }
}

public struct StatusLabel: View {
    public let icon: String
    public let message: String
    public let color: Color

    public init(icon: String, message: String, color: Color = .statusOrange) {
        self.icon = icon
        self.message = message
        self.color = color
    }

    public var body: some View {
        Label(message, systemImage: icon)
            .biteBeatFont(.caption)
            .foregroundStyle(color)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    VStack(spacing: 12) {
        StatusBanner(
            icon: "music.note",
            title: "Connect Apple Music to get your listening history.",
            subtitle: "These are sample playlists."
        )
        StatusLabel(
            icon: "exclamationmark.triangle.fill",
            message: "Access denied. Check Settings.",
            color: .statusOrange
        )
    }
    .padding()
}
