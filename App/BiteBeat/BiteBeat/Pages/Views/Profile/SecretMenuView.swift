//
//  SecretMenuView.swift
//  BiteBeat
//

import SwiftData
import SwiftUI

struct SecretMenuView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // Global AppStorage bindings corresponding to UserDefaults keys used in MusicToFoodAnalyzer
    @AppStorage("overrideAnalyzerMode") private var analyzerMode: String = "auto"
    @AppStorage("analyzerLanguage") private var analyzerLanguage: String = "english"
    
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Analyzer Configuration")) {
                    Picker("Operation Mode", selection: $analyzerMode) {
                        Text("Auto (nearby restaurants)").tag("auto")
                        Text("Force Creative").tag("forceCreative")
                    }
                    
                    Picker("Prompt Language", selection: $analyzerLanguage) {
                        Text("English").tag("english")
                        Text("Indonesian").tag("indonesian")
                    }
                }
                
                Section(header: Text("Debug Actions")) {
                    Button(role: .destructive) {
                        MealRecordStore.resetTodaySelection(in: modelContext)
                        NotificationCenter.default.post(name: NSNotification.Name("ResetHome"), object: nil)
                        showResetAlert = true
                    } label: {
                        Label("Reset Today's Mood Analysis", systemImage: "arrow.counterclockwise")
                    }
                }
                
                Section(footer: Text("Changes apply to the next analysis session. Auto falls back to Creative when location is unavailable or no nearby restaurants are found.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Secret Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
            .alert("Success", isPresented: $showResetAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Today's mood analysis status has been reset. You can now perform a new analysis on the Home screen.")
            }
        }
    }
}

#Preview {
    SecretMenuView()
}
