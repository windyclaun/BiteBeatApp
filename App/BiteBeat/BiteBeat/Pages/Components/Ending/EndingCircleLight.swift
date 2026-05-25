import SwiftUI

struct EndingCircleLight: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var animateLight = false

    let imageSize: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.24))
                .frame(width: imageSize * 1.08, height: imageSize * 1.08)
                .blur(radius: 22)
                .scaleEffect(reduceMotion ? 1 : (animateLight ? 1.12 : 0.9))

            Circle()
                .fill(.white.opacity(0.18))
                .frame(width: imageSize * 0.88, height: imageSize * 0.88)
                .blur(radius: 18)
                .offset(
                    x: reduceMotion ? 0 : (animateLight ? imageSize * 0.12 : -imageSize * 0.10),
                    y: reduceMotion ? 0 : (animateLight ? -imageSize * 0.08 : imageSize * 0.08)
                )

            Circle()
                .fill(.pink.opacity(0.22))
                .frame(width: imageSize * 0.74, height: imageSize * 0.74)
                .blur(radius: 26)
                .offset(
                    x: reduceMotion ? 0 : (animateLight ? -imageSize * 0.16 : imageSize * 0.14),
                    y: reduceMotion ? 0 : (animateLight ? imageSize * 0.12 : -imageSize * 0.10)
                )
        }
        .animation(
            reduceMotion ? nil : .easeInOut(duration: 2.4).repeatForever(autoreverses: true),
            value: animateLight
        )
        .onAppear {
            guard !reduceMotion else { return }
            animateLight = true
        }
        .onDisappear {
            animateLight = false
        }
    }
}
