import BiteBeatMusic
import MusicKit
import SwiftUI

struct AnalysisLoadingView: View {
    let songsToAnalyze: [Song]
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var pulseScale: CGFloat = 0.85
    @State private var rotateDegree = 0.0
    @State private var loadingStatus = "Accessing Apple Music History…"
    @State private var calculatedVibe: MusicVibe?
    @State private var calculatedMain: Meal?
    @State private var calculatedAlternatives: [Meal] = []
    
    @State private var navigateToRecommendation = false
    
    var body: some View {
        NavigationStack {
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
                
                .navigationDestination(isPresented: $navigateToRecommendation) {
                    if let vibe = calculatedVibe, let main = calculatedMain {
                        RecommendationView(
                            vibe: vibe,
                            mainMeal: main,
                            alternatives: calculatedAlternatives
                        )
                    }
                }
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
            .task {
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    pulseScale = 1.05
                }
                withAnimation(.linear(duration: 3.5).repeatForever(autoreverses: false)) {
                    rotateDegree = 360.0
                }
                
                await sleep(1.0)
                loadingStatus = "Scanning 10 Recently Played Tracks…"
                let analyzer = MusicToFoodAnalyzer()
                let result = analyzer.analyze(songs: songsToAnalyze)
                calculatedVibe = result.vibe
                calculatedMain = result.mainMeal
                calculatedAlternatives = result.alternatives
                
                await sleep(1.0)
                if let vibe = calculatedVibe {
                    loadingStatus = "Matching your mood to \(vibe.rawValue)…"
                }
                
                await sleep(1.0)
                loadingStatus = "Assembling the perfect match!"
                await sleep(0.6)
                
                navigateToRecommendation = true
            }
        }
    }
    
    private func sleep(_ seconds: TimeInterval) async {
        try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}

#Preview {
    AnalysisLoadingView(songsToAnalyze: [])
}
