import SwiftUI

struct EndingGreetingText: View {
    let greeting: String

    var body: some View {
        Text(greeting)
            .biteBeatFont(.custom(34), weight: .bold)
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.8)
            .lineLimit(1)
            .padding(.horizontal, 32)
    }
}
