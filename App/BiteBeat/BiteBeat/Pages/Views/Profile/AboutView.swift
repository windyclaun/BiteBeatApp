//
//  AboutView.swift
//  BiteBeat
//

import SwiftUI

struct AboutView: View {
    @State private var secretTapCount = 0
    @State private var showSecretMenu = false
    
    private let teamMembers = [
        "Aulia Fajriyah",
        "Muhammad Hisyam Kamil",
        "Michelle Handa",
        "Windy Napitupulu",
        "Noor Akhnafal Aban"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Header Logo
            VStack(spacing: 8) {
                Image(systemName: "music.note.house.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.pink.gradient)
                
                Text("BiteBeat")
                    .font(.largeTitle.bold())
                    .tracking(2)
            }
            .contentShape(Rectangle()) // Make the whole area tappable
            .onTapGesture {
                secretTapCount += 1
                if secretTapCount >= 7 {
                    showSecretMenu = true
                    secretTapCount = 0 // Reset
                }
            }
            .padding(.bottom, 40)
            
            // Team Members Grid/List
            VStack(spacing: 16) {
                Text("Created By")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                VStack(spacing: 12) {
                    ForEach(teamMembers, id: \.self) { member in
                        Text(member)
                            .font(.title3.weight(.medium))
                            .foregroundStyle(.primary)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
                            )
                    }
                }
                .padding(.horizontal, 32)
            }
            
            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
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
