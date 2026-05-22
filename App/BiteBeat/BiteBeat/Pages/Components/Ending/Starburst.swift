import SwiftUI

struct Starburst: View {
    let size: CGSize
    let center: CGPoint

    var body: some View {
        ZStack {
            BurstRay(
                center: center,
                first: CGPoint(x: 0, y: size.height * 0.27),
                second: CGPoint(x: 0, y: size.height * 0.43),
                opacity: 0.34
            )

            BurstRay(
                center: center,
                first: CGPoint(x: 0, y: size.height * 0.47),
                second: CGPoint(x: 0, y: size.height * 0.67),
                opacity: 0.22
            )

            BurstRay(
                center: center,
                first: CGPoint(x: size.width, y: size.height * 0.31),
                second: CGPoint(x: size.width, y: size.height * 0.42),
                opacity: 0.26
            )

            BurstRay(
                center: center,
                first: CGPoint(x: size.width, y: size.height * 0.47),
                second: CGPoint(x: size.width, y: size.height * 0.60),
                opacity: 0.18
            )
        }
    }
}
