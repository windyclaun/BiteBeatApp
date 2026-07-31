import SwiftUI

struct AboutView: View {
    @State private var secretTapCount = 0
    @State private var showSecretMenu = false
    @State private var didShuffle = false

    @State private var teamMembers = [
        "Aulia Fajriyah",
        "Muhammad Hisyam Kamil",
        "Michelle Handa",
        "Windy Napitupulu",
        "Noor Akhnafal Aban"
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 8) {
                Image("LogoApp")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .padding(16)
                    .background(
                        Circle()
                            .fill(Color.statusRed.gradient)
                    )
                    .shadow(color: .statusRed.opacity(0.3), radius: 8, y: 4)

                Text("BiteBeat")
                    .biteBeatFont(.largeTitle, weight: .bold)
                    .tracking(2)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                secretTapCount += 1
                if secretTapCount >= 7 {
                    showSecretMenu = true
                    secretTapCount = 0
                }
            }
            .padding(.bottom, 40)

            VStack(spacing: 16) {
                VStack(spacing: 4) {
                    Text("Created By")
                        .biteBeatFont(.headline)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)

                    Text("Team pUcak Gunung")
                        .biteBeatFont(.title3, weight: .bold)
                        .foregroundStyle(Color.accentColor)
                }

                VStack(spacing: 12) {
                    ForEach(teamMembers, id: \.self) { member in
                        Text(member)
                            .biteBeatFont(.title3, weight: .medium)
                            .foregroundStyle(.primary)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color(.secondarySystemGroupedBackground))
                                    .shadowStyle(radius: 2, y: 1, opacity: 0.05)
                            )
                    }
                }
                .padding(.horizontal, 32)
            }

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            guard !didShuffle else { return }
            didShuffle = true
            teamMembers.shuffle()
        }
        .sheet(isPresented: $showSecretMenu) {
            SecretMenuView()
        }
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}
