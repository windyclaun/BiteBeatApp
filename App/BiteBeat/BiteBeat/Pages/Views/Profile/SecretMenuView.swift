//
//  SecretMenuView.swift
//  BiteBeat
//

import SwiftUI

struct SecretMenuView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("analyzerLanguage") private var analyzerLanguage: String = "english"

    @State private var showResetAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Analyzer Configuration")) {
                    Picker("Prompt Language", selection: $analyzerLanguage) {
                        Text("English").tag("english")
                        Text("Indonesian").tag("indonesian")
                    }
                }

                Section(header: Text("Debug Actions")) {
                    Button(role: .destructive) {
                        DailyMealSelectionStore.resetTodaySelection()
                        NotificationCenter.default.post(name: .resetHome, object: nil)
                        showResetAlert = true
                    } label: {
                        Label("Reset Today's Mood Analysis", systemImage: "arrow.counterclockwise")
                    }
                }

                Section(footer: Text("Changes apply to the next analysis session.")) {
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
