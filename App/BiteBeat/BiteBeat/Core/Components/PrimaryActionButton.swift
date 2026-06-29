import SwiftUI

public struct PrimaryActionButton: View {
    public let title: String
    public let isLoading: Bool
    public let action: () -> Void

    public init(title: String, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Group {
                if isLoading {
                    ProgressView()
                        .tint(.onAccent)
                } else {
                    Text(title)
                        .biteBeatFont(.subheadline, weight: .bold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .buttonStyle(.glassProminent)
        .tint(Color.accentColor)
        .disabled(isLoading)
    }
}

#Preview {
    VStack(spacing: 12) {
        PrimaryActionButton(title: "Yay!") {}
        PrimaryActionButton(title: "Loading...", isLoading: true) {}
    }
    .padding()
}
