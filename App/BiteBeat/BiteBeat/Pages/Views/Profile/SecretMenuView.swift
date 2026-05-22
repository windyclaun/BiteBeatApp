//
//  SecretMenuView.swift
//  BiteBeat
//

import SwiftUI

struct SecretMenuView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Global AppStorage bindings corresponding to UserDefaults keys used in MusicToFoodAnalyzer
    @AppStorage("overrideAnalyzerMode") private var analyzerMode: String = "auto"
    @AppStorage("analyzerLanguage") private var analyzerLanguage: String = "english"
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Analyzer Configuration")) {
                    Picker("Operation Mode", selection: $analyzerMode) {
                        Text("Auto (foods.json if available)").tag("auto")
                        Text("Force Creative").tag("forceCreative")
                        Text("Force Database").tag("forceDatabase")
                    }
                    
                    Picker("Prompt Language", selection: $analyzerLanguage) {
                        Text("English").tag("english")
                        Text("Indonesian").tag("indonesian")
                    }
                }
                
                Section(footer: Text("Changes apply to the next analysis session. Force Database will still fail safely to Creative if the foods.json asset is truly missing.")) {
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
        }
    }
}

#Preview {
    SecretMenuView()
}
