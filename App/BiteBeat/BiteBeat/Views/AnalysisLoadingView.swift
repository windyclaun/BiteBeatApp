import BiteBeatMusic
import MusicKit
import SwiftUI

struct ConsoleLog: Identifiable, Equatable {
    let id = UUID()
    let text: String
}

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
    @State private var neuralLogs: [ConsoleLog] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: AppleIntelligenceManager.shared.isAppleIntelligenceActive ? [.blue, .purple, .pink, .orange] : [.pink, .purple, .orange],
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
                                colors: AppleIntelligenceManager.shared.isAppleIntelligenceActive ? [.blue, .purple, .pink, .orange, .blue] : [.pink, .purple, .orange, .pink],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 6
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(rotateDegree))
                    
                    Circle()
                        .fill(LinearGradient(
                            colors: AppleIntelligenceManager.shared.isAppleIntelligenceActive ? [.blue, .purple] : [.pink, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 80, height: 80)
                        .scaleEffect(pulseScale)
                        .overlay {
                            Image(systemName: AppleIntelligenceManager.shared.isAppleIntelligenceActive ? "apple.intelligence" : "sparkles")
                                .font(.system(size: 32))
                                .foregroundStyle(.white)
                                .symbolEffect(.bounce, options: .repeating)
                        }
                }
                .padding(.bottom, 24)
                
                VStack(spacing: 8) {
                    Text(AppleIntelligenceManager.shared.isAppleIntelligenceActive ? "Apple Intelligence" : "Heuristic Analyzer")
                        .font(.headline)
                        .foregroundStyle(
                            LinearGradient(
                                colors: AppleIntelligenceManager.shared.isAppleIntelligenceActive ? [.blue, .purple, .pink] : [.pink, .orange],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
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
                
                if !neuralLogs.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(.green)
                                .frame(width: 6, height: 6)
                            Text("Apple Neural Engine Console:")
                                .font(.system(.caption, design: .monospaced))
                                .bold()
                                .foregroundStyle(.pink.opacity(0.8))
                        }
                        .padding(.bottom, 2)
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(neuralLogs) { log in
                                    Text(log.text)
                                        .font(.system(size: 11, design: .monospaced))
                                        .foregroundStyle(.primary.opacity(0.85))
                                        .transition(.move(edge: .bottom).combined(with: .opacity))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(height: 110)
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.quaternary, lineWidth: 1)
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }
                
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
                
                let isAIActive = AppleIntelligenceManager.shared.isAppleIntelligenceActive
                
                if isAIActive {
                    loadingStatus = "Menghubungkan ke Apple Intelligence..."
                    await sleep(0.8)
                    
                    let analyzer = MusicToFoodAnalyzer()
                    let result = await analyzer.analyzeWithAppleIntelligence(songs: songsToAnalyze)
                    
                    calculatedVibe = result.vibe
                    calculatedMain = result.mainMeal
                    calculatedAlternatives = result.alternatives
                    
                    for log in result.logs {
                        withAnimation(.easeOut(duration: 0.3)) {
                            neuralLogs.append(ConsoleLog(text: log))
                        }
                        loadingStatus = log.replacingOccurrences(of: "⚡️ ", with: "")
                                           .replacingOccurrences(of: "🧠 ", with: "")
                                           .replacingOccurrences(of: "📊 ", with: "")
                                           .replacingOccurrences(of: "🔎 ", with: "")
                                           .replacingOccurrences(of: "🎯 ", with: "")
                                           .replacingOccurrences(of: "🍽️ ", with: "")
                                           .replacingOccurrences(of: "[ANE] ", with: "")
                                           .replacingOccurrences(of: "[Apple Intelligence] ", with: "")
                        await sleep(0.65)
                    }
                    await sleep(0.5)
                } else {
                    await sleep(1.0)
                    loadingStatus = "Scanning 10 Recently Played Tracks…"
                    let analyzer = MusicToFoodAnalyzer()
                    let result = await analyzer.analyze(songs: songsToAnalyze)
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
                }
                
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
