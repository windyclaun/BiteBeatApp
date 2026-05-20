import BiteBeatMusic
import MusicKit
import SwiftUI

struct AnalysisLoadingView: View {
    // KEMBALIKAN KE: [Song] bawaan MusicKit agar bisa masuk ke analyzer tanpa error
    let songsToAnalyze: [Song]
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var pulseScale: CGFloat = 0.85
    @State private var rotateDegree = 0.0
    @State private var loadingStatus = "Accessing Apple Music History…"
    @State private var calculatedVibeName: String?
    @State private var calculatedVibeDescription: String?
    @State private var calculatedMain: Meal?
    @State private var calculatedAlternatives: [Meal] = []
    
    @State private var navigateToRecommendation = false
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.pink, .purple, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 140, height: 140)
                    .scaleEffect(pulseScale)
                    .blur(radius: 20)
                    .opacity(0.6)
                
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.pink, .purple, .orange, .pink],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 6
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(rotateDegree))
                
                Circle()
                    .fill(LinearGradient(
                        colors: [.pink, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 80, height: 80)
                    .scaleEffect(pulseScale)
                    .overlay {
                        Image(systemName: "sparkles")
                            .font(.system(size: 32))
                            .foregroundStyle(.white)
                            .symbolEffect(.bounce, options: .repeating)
                    }
            }
            .padding(.bottom, 48)
            
            VStack(spacing: 8) {
                Text("Apple Intelligence")
                    .font(.headline)
                    .foregroundStyle(.pink.gradient)
                    .textCase(.uppercase)
                    .tracking(2.0)
                
                Text(loadingStatus)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .contentTransition(.identity)
            }
            .frame(height: 80)
            .padding(.horizontal)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundStyle(.secondary)
            }
        }
        .navigationDestination(isPresented: $navigateToRecommendation) {
            if let vibeName = calculatedVibeName, let main = calculatedMain {
                RecommendationView(
                    vibeName: vibeName,
                    mainMeal: main,
                    alternatives: calculatedAlternatives
                )
            }
        }
        .task {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulseScale = 1.05
            }
            withAnimation(.linear(duration: 3.5).repeatForever(autoreverses: false)) {
                rotateDegree = 360.0
            }
            
            await sleep(1.0)
            loadingStatus = "Scanning 10 Recently Played Tracks…"
            
            if #available(iOS 26.0, *) {
                let analyzer = MusicToFoodAnalyzer()
                do {
                    let result = try await analyzer.analyze(songs: songsToAnalyze)
                    calculatedVibeName = result.vibeName
                    calculatedVibeDescription = result.vibeDescription
                    calculatedMain = result.mainMeal
                    calculatedAlternatives = result.alternatives
                } catch {
                    calculatedVibeName = "Error Analyzing"
                    calculatedVibeDescription = "Failed to load from Apple Intelligence."
                    calculatedMain = Meal(title: "Fallback Nasi Goreng", price: "Rp 25.000", location: "-", calories: "-", description: "-", systemImage: "flame.fill", gradientColors: ["orange", "red"])
                    calculatedAlternatives = []
                }
            } else {
                calculatedVibeName = "Classic Mix"
                calculatedVibeDescription = "Apple Intelligence requires iOS 26.0 or newer."
                calculatedMain = Meal(title: "Fallback Nasi Goreng", price: "Rp 25.000", location: "-", calories: "-", description: "-", systemImage: "flame.fill", gradientColors: ["orange", "red"])
                calculatedAlternatives = []
            }
            
            await sleep(1.0)
            if let vibe = calculatedVibeName {
                loadingStatus = "Matching your mood to \(vibe)…"
            }
            
            await sleep(1.0)
            loadingStatus = "Assembling the perfect match!"
            await sleep(0.6)
            
            navigateToRecommendation = true
        }
    }
    
    private func sleep(_ seconds: TimeInterval) async {
        try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}

#Preview {
    NavigationStack {
        AnalysisLoadingView(songsToAnalyze: [])
    }
}
