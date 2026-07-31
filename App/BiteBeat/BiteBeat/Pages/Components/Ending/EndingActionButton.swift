import SwiftUI

struct EndingActionButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text("Let's Eat!")
                .biteBeatFont(.body, weight: .bold)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
        }
        .buttonStyle(.glassProminent)
        .tint(Color.accentColor)
    }
}