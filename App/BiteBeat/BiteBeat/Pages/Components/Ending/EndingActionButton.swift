import SwiftUI

struct EndingActionButton: View {
    var body: some View {
        Button {
            NotificationCenter.default.post(name: NSNotification.Name("ResetHome"), object: nil)
        } label: {
            Text("Let's Eat !")
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    Capsule()
                        .fill(Color(red: 0.82, green: 0.0, blue: 0.17))
                )
                .overlay {
                    Capsule()
                        .stroke(.white.opacity(0.32), lineWidth: 1.5)
                }
                .shadow(color: .black.opacity(0.14), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}
