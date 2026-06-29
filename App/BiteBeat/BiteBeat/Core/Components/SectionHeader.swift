import SwiftUI

public struct SectionHeader: View {
    public let title: String
    public let trailing: String?

    public init(title: String, trailing: String? = nil) {
        self.title = title
        self.trailing = trailing
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .biteBeatFont(.title, weight: .bold)

            if let trailing {
                Spacer()
                Text(trailing)
                    .biteBeatFont(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    SectionHeader(title: "History", trailing: "Recent picks")
        .padding()
}
