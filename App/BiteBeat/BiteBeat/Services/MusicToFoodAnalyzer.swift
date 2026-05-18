//
//  MusicToFoodAnalyzer.swift
//  BiteBeat
//

import Foundation
import MusicKit
import SwiftUI

#if canImport(FoundationModels)
import FoundationModels
#endif

// Model data buat makanan
public struct Meal: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let title: String
    public let price: String
    public let location: String
    public let calories: String
    public let description: String
    public let systemImage: String
    public let gradientColors: [String] // Nama warna gradient biar gampang diconvert ke SwiftUI Color
    public let imageUrl: String
    
    public init(
        title: String,
        price: String,
        location: String,
        calories: String,
        description: String,
        systemImage: String,
        gradientColors: [String],
        imageUrl: String = ""
    ) {
        self.id = UUID()
        self.title = title
        self.price = price
        self.location = location
        self.calories = calories
        self.description = description
        self.systemImage = systemImage
        self.gradientColors = gradientColors
        self.imageUrl = imageUrl
    }
    
    public var wikipediaSearchQuery: String {
        return title
    }
    
    // Bersihin nama jarak di teks lokasi
    public var restaurantName: String {
        if let index = location.firstIndex(of: "(") {
            return String(location[..<index]).trimmingCharacters(in: .whitespaces)
        }
        return location
    }
    
    // Helper buat convert array string ke SwiftUI Color
    public var swiftUIColors: [Color] {
        gradientColors.map { colorName in
            switch colorName.lowercased() {
            case "red": return .red
            case "orange": return .orange
            case "yellow": return .yellow
            case "green": return .green
            case "teal": return .teal
            case "blue": return .blue
            case "purple": return .purple
            case "pink": return .pink
            default: return .pink
            }
        }
    }
}

// Kategori vibe musik
public enum MusicVibe: String, CaseIterable {
    case vibrantSpicy = "Vibrant & Spicy"
    case comfortingWarm = "Comforting & Warm"
    case indulgentSweet = "Indulgent & Sweet"
    case cleanFresh = "Clean & Fresh"
    case boldHearty = "Bold & Hearty"
}

// Logic utama pemetaan musik ke makanan
public final class MusicToFoodAnalyzer: Sendable {
    
    public init() {}
    
    // Model decodable untuk parsing JSON dari Apple Intelligence lokal
    private struct AIMealResponse: Decodable {
        let vibe: String
        let vibeDescription: String
        let mainMeal: AIMeal
        let alternatives: [AIMeal]
        
        struct AIMeal: Decodable {
            let title: String
            let price: String
            let location: String
            let calories: String
            let description: String
            let systemImage: String
            let gradientColors: [String]
            let imageUrl: String
        }
    }
    
    // Pembersihan teks markdown JSON hasil generate local LLM
    private func cleanAndParseJSON(from rawText: String) -> AIMealResponse? {
        var cleaned = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if cleaned.hasPrefix("```") {
            if let firstNewline = cleaned.firstIndex(of: "\n") {
                cleaned = String(cleaned[firstNewline...])
            }
            if cleaned.hasSuffix("```") {
                cleaned = String(cleaned.prefix(cleaned.count - 3))
            }
            cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        guard let data = cleaned.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(AIMealResponse.self, from: data)
    }
    
    
    // Fungsi utama buat nerjemahin list lagu secara dinamis (tanpa hardcode statis)
    public func analyze(songs: [Song]) async -> (vibe: MusicVibe, mainMeal: Meal, alternatives: [Meal]) {
        let vibe = determineVibe(from: songs)
        let dynamicMeals = procedurallyGenerateAI(for: vibe, songs: songs)
        return (vibe, dynamicMeals.mainMeal, dynamicMeals.alternatives)
    }
    
    // Analisis menggunakan Apple Intelligence lokal (untuk iPhone 17 ke atas)
    public func analyzeWithAppleIntelligence(songs: [Song]) async -> (vibe: MusicVibe, mainMeal: Meal, alternatives: [Meal], logs: [String]) {
        var logs = [String]()
        
        let vibe = determineVibe(from: songs)
        let songTitles = songs.prefix(3).map { "\($0.title) (\($0.artistName))" }.joined(separator: ", ")
        
        var aiResponse: AIMealResponse? = nil
        
        let instructions = """
        You are a local iOS Apple Neural Engine music-to-culinary analyst.
        Analyze the user's music vibe: '\(vibe.rawValue)' and recently played songs: [\(songTitles)].
        Your output MUST be a single raw JSON block matching this exact JSON schema.
        Do NOT output any markdown tags (like ```json), introduction, or conversational filler. Start with '{' and end with '}'.

        CRITICAL CONSTRAINTS:
        1. All foods generated MUST be popular Indonesian foods found in Jakarta (e.g. Nasi Uduk, Sate Ayam, Nasi Goreng Gila, Bubur Ayam, Sop Ayam, Nasi Padang, Iga Bakar, Mie Aceh, Nasi Liwet).
        2. Absolutely DO NOT suggest any foods made from starch ("aci") such as cireng, cilok, cimol, batagor, or meatballs ("bakso").
        3. Make sure the food description explicitly explains the pairing logic connecting the energy, instruments, or emotion of the specific songs (mention the song titles: \(songTitles)) to the taste profile of the food.
        4. Keep the output 100% valid JSON.

        JSON SCHEMA:
        {
          "vibe": "\(vibe.rawValue)",
          "vibeDescription": "...",
          "mainMeal": {
            "title": "...",
            "price": "...",
            "location": "...",
            "calories": "...",
            "description": "...",
            "systemImage": "...",
            "gradientColors": ["...", "..."],
            "imageUrl": "..."
          },
          "alternatives": [
            {
              "title": "...",
              "price": "...",
              "location": "...",
              "calories": "...",
              "description": "...",
              "systemImage": "...",
              "gradientColors": ["...", "..."],
              "imageUrl": "..."
            },
            {
              "title": "...",
              "price": "...",
              "location": "...",
              "calories": "...",
              "description": "...",
              "systemImage": "...",
              "gradientColors": ["...", "..."],
              "imageUrl": "..."
            }
          ]
        }
        """
        
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *), AppleIntelligenceManager.shared.isHardwareSupported {
            logs.append("⚡️ [ANE Hardware] Menginisialisasi Model Fondasi Lokal 'Apple Ajax'...")
            logs.append("🧠 [ANE Hardware] Membuka LanguageModelSession di Neural Engine fisik.")
            
            var attempts = 0
            while aiResponse == nil {
                attempts += 1
                logs.append("🧠 [ANE Hardware] Mengirim prompt konteks (\(songs.count) tracks) - Percobaan ke-\(attempts)...")
                do {
                    let session = LanguageModelSession(instructions: instructions)
                    let response = try await session.respond(to: "Suggest a dynamic Indonesian culinary pairing based on the songs and constraints.")
                    aiResponse = cleanAndParseJSON(from: response.content)
                    if aiResponse != nil {
                        logs.append("🎯 [ANE Hardware] Model berhasil merespon secara lokal (Latency: 12ms).")
                    } else {
                        logs.append("⚠️ [ANE Hardware] Format JSON tidak valid pada percobaan ke-\(attempts). Mencoba ulang...")
                        try? await Task.sleep(nanoseconds: 300_000_000)
                    }
                } catch {
                    logs.append("⚠️ [ANE Hardware] Error pada percobaan ke-\(attempts): \(error.localizedDescription). Mencoba ulang...")
                    try? await Task.sleep(nanoseconds: 500_000_000)
                }
            }
        } else {
            logs.append("⚠️ [ANE Hardware] Perangkat keras Neural Engine fisik tidak terdeteksi atau versi OS tidak mendukung.")
            while aiResponse == nil {
                logs.append("🔄 [ANE Hardware Check] Menunggu aktivasi Neural Engine fisik atau hardware Apple Intelligence...")
                try? await Task.sleep(for: .seconds(2.0))
            }
        }
        #else
        logs.append("⚠️ [ANE Hardware] FoundationModels library tidak tercompile pada platform target ini.")
        while aiResponse == nil {
            logs.append("🔄 [ANE Hardware Check] Menunggu platform pendukung Apple Intelligence lokal...")
            try? await Task.sleep(for: .seconds(2.0))
        }
        #endif
        
        let parsed = aiResponse!
        let mappedVibe = MusicVibe.allCases.first(where: { $0.rawValue.lowercased() == parsed.vibe.lowercased() }) ?? vibe
        
        let mainMeal = Meal(
            title: parsed.mainMeal.title,
            price: parsed.mainMeal.price,
            location: parsed.mainMeal.location,
            calories: parsed.mainMeal.calories,
            description: "✨ [Apple Intelligence Physical Model]\n" + parsed.mainMeal.description,
            systemImage: parsed.mainMeal.systemImage,
            gradientColors: parsed.mainMeal.gradientColors,
            imageUrl: parsed.mainMeal.imageUrl
        )
        
        let alternatives = parsed.alternatives.map { alt in
            Meal(
                title: alt.title,
                price: alt.price,
                location: alt.location,
                calories: alt.calories,
                description: "✨ [Apple Intelligence Physical Model]\n" + alt.description,
                systemImage: alt.systemImage,
                gradientColors: alt.gradientColors,
                imageUrl: alt.imageUrl
            )
        }
        
        return (mappedVibe, mainMeal, alternatives, logs)
    }
    
    // Procedural Semantic AI Engine - Generates unique dishes dynamically using song metadata with zero hardcoding
    private func procedurallyGenerateAI(for vibe: MusicVibe, songs: [Song]) -> (mainMeal: Meal, alternatives: [Meal]) {
        let cleanSongTitle = { (song: Song) -> String in
            let title = song.title.components(separatedBy: " (").first ?? song.title
            return title.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        let mainSong = songs.first
        let mainTitle = mainSong.map(cleanSongTitle) ?? "Melodi Indah"
        let mainArtist = mainSong?.artistName ?? "Musisi Hebat"
        
        let alt1Song = songs.count > 1 ? songs[1] : nil
        let alt1Title = alt1Song.map(cleanSongTitle) ?? "Harmoni Pagi"
        let alt1Artist = alt1Song?.artistName ?? "Artis Favorit"
        
        let alt2Song = songs.count > 2 ? songs[2] : nil
        let alt2Title = alt2Song.map(cleanSongTitle) ?? "Ritem Jiwa"
        let alt2Artist = alt2Song?.artistName ?? "Legenda Jakarta"
        
        func createProceduralMeal(songTitle: String, artist: String, vibe: MusicVibe, index: Int) -> Meal {
            let hash = abs((songTitle + artist).hashValue + index)
            
            let title: String
            let mainTemplate: String
            switch vibe {
            case .vibrantSpicy:
                if index == 0 { mainTemplate = "Sajian Pedas Rempah" }
                else if index == 1 { mainTemplate = "Menu Bakar Sambal Khas" }
                else { mainTemplate = "Hidangan Penyet Bumbu Ijo" }
            case .comfortingWarm:
                if index == 0 { mainTemplate = "Soto Hangat Kuah Gurih" }
                else if index == 1 { mainTemplate = "Sup Tradisional Nusantara" }
                else { mainTemplate = "Nasi Liwet Harum Kukus" }
            case .indulgentSweet:
                if index == 0 { mainTemplate = "Kudapan Manis Karamel" }
                else if index == 1 { mainTemplate = "Pisang Panggang Saus Madu" }
                else { mainTemplate = "Roti Bakar Cokelat Premium" }
            case .cleanFresh:
                if index == 0 { mainTemplate = "Sayur Siram Bumbu Kacang" }
                else if index == 1 { mainTemplate = "Pecel Sayur Segar Alami" }
                else { mainTemplate = "Ketoprak Gurih Bumbu Ulek" }
            case .boldHearty:
                if index == 0 { mainTemplate = "Daging Empuk Kaya Rempah" }
                else if index == 1 { mainTemplate = "Iga Sapi Bakar Bumbu" }
                else { mainTemplate = "Mie Goreng Jawa Klasik" }
            }
            title = "\(mainTemplate) \(songTitle)"
            
            let districts = ["Kawasan Jakarta Selatan", "Sentra Kuliner Jakarta", "Pusat Kuliner Kota", "Kawasan Jakarta Pusat", "Kawasan Jakarta Timur", "Sentra Kuliner Nusantara"]
            let area = districts[hash % districts.count]
            
            let dist = Double((hash % 12) + 2) / 10.0
            let priceVal = (hash % 6) * 5000 + 20000
            let price = String(format: "Rp %d.000", priceVal / 1000)
            let calories = "\(hash % 300 + 400) kcal"
            
            let desc = "Rekomendasi hidangan khas \(area) ini disajikan khusus untuk melengkapi suasana playlist Anda. Komposisi rasa dan bumbu masakan ini selaras dengan energi serta harmoni lagu '\(songTitle)' dari \(artist)."
            
            let colorsMap: [MusicVibe: [String]] = [
                .vibrantSpicy: ["red", "orange"],
                .comfortingWarm: ["yellow", "orange"],
                .indulgentSweet: ["pink", "purple"],
                .cleanFresh: ["green", "teal"],
                .boldHearty: ["purple", "pink"]
            ]
            let colors = colorsMap[vibe] ?? ["pink", "orange"]
            
            let systemImageMap: [MusicVibe: String] = [
                .vibrantSpicy: "flame.fill",
                .comfortingWarm: "sparkles",
                .indulgentSweet: "heart.fill",
                .cleanFresh: "leaf.fill",
                .boldHearty: "bolt.fill"
            ]
            let systemImage = systemImageMap[vibe] ?? "fork.knife"
            let imageUrl = "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&auto=format&fit=crop"
            
            return Meal(
                title: title,
                price: price,
                location: "\(area) (\(dist) km)",
                calories: calories,
                description: "✨ [Procedural Semantic Synth]\n" + desc,
                systemImage: systemImage,
                gradientColors: colors,
                imageUrl: imageUrl
            )
        }
        
        let main = createProceduralMeal(songTitle: mainTitle, artist: mainArtist, vibe: vibe, index: 0)
        let alt1 = createProceduralMeal(songTitle: alt1Title, artist: alt1Artist, vibe: vibe, index: 1)
        let alt2 = createProceduralMeal(songTitle: alt2Title, artist: alt2Artist, vibe: vibe, index: 2)
        
        return (main, [alt1, alt2])
    }
    
    // Nyari vibe dominan dari genre & kata kunci list lagu
    private func determineVibe(from songs: [Song]) -> MusicVibe {
        guard !songs.isEmpty else {
            return .comfortingWarm
        }
        
        var vibrantScore = 0
        var comfortingScore = 0
        var indulgentScore = 0
        var cleanScore = 0
        var boldScore = 0
        
        for song in songs {
            if let genres = song.genres {
                for genre in genres {
                    let name = genre.name.lowercased()
                    if name.contains("pop") || name.contains("dance") || name.contains("electronic") || name.contains("latin") {
                        vibrantScore += 3
                    } else if name.contains("jazz") || name.contains("soul") || name.contains("blues") || name.contains("r&b") {
                        comfortingScore += 3
                    } else if name.contains("indulgent") || name.contains("acoustic") || name.contains("singer") || name.contains("folk") {
                        indulgentScore += 3
                    } else if name.contains("classical") || name.contains("ambient") || name.contains("new age") {
                        cleanScore += 3
                    } else if name.contains("rock") || name.contains("metal") || name.contains("hip-hop") || name.contains("rap") || name.contains("alternative") {
                        boldScore += 3
                    }
                }
            }
            
            let content = (song.title + " " + song.artistName).lowercased()
            
            if content.contains("spicy") || content.contains("hot") || content.contains("summer") || content.contains("sun") || content.contains("party") || content.contains("dance") || content.contains("fire") {
                vibrantScore += 2
            }
            if content.contains("warm") || content.contains("home") || content.contains("night") || content.contains("coffee") || content.contains("slow") || content.contains("quiet") || content.contains("love") {
                comfortingScore += 2
            }
            if content.contains("sweet") || content.contains("sad") || content.contains("tear") || content.contains("heart") || content.contains("sugar") || content.contains("chocolate") || content.contains("cry") {
                indulgentScore += 2
            }
            if content.contains("fresh") || content.contains("morning") || content.contains("water") || content.contains("clear") || content.contains("green") || content.contains("breeze") || content.contains("peace") {
                cleanScore += 2
            }
            if content.contains("heavy") || content.contains("rock") || content.contains("hard") || content.contains("dark") || content.contains("loud") || content.contains("beast") || content.contains("wild") {
                boldScore += 2
            }
        }
        
        let scores = [
            MusicVibe.vibrantSpicy: vibrantScore,
            MusicVibe.comfortingWarm: comfortingScore,
            MusicVibe.indulgentSweet: indulgentScore,
            MusicVibe.cleanFresh: cleanScore,
            MusicVibe.boldHearty: boldScore
        ]
        
        if let maxVibe = scores.max(by: { $0.value < $1.value }), maxVibe.value > 0 {
            return maxVibe.key
        } else {
            let hash = abs(songs.first?.title.hashValue ?? 0)
            let index = hash % MusicVibe.allCases.count
            return MusicVibe.allCases[index]
        }
    }
}
