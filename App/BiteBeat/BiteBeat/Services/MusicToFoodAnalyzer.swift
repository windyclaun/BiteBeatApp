import Foundation
import MusicKit
import SwiftUI
import FoundationModels

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

// Data structures for AI Response decoding
fileprivate struct AIResponse: Codable {
    let vibeName: String
    let vibeDescription: String
    let mainMeal: AIMeal
    let alternatives: [AIMeal]
}

fileprivate struct AIMeal: Codable {
    let title: String
    let price: String
    let location: String
    let calories: String
    let description: String
    let systemImage: String
    let gradientColors: [String]
}

@available(iOS 26.0, *)
public final class MusicToFoodAnalyzer: Sendable {
    
    public init() {}
    
    // Fungsi utama buat nerjemahin list lagu ke vibe makanan (dapat menu utama & 2 alternatif)
    public func analyze(songs: [Song]) async throws -> (vibeName: String, vibeDescription: String, mainMeal: Meal, alternatives: [Meal]) {
        let songsList = songs.isEmpty ? "No recent songs, default to soft and calming music." : songs.map { "- \($0.title) by \($0.artistName)" }.joined(separator: "\n")
        
        let promptText = """
        You are a food and music expert. Analyze these recently played songs and recommend 3 Indonesian food dishes (1 main, 2 alternatives).
        Songs:
        \(songsList)

        Respond EXACTLY in this JSON format without any markdown blocks or extra text:
        {
          "vibeName": "Short vibe name (e.g. Vibrant & Spicy)",
          "vibeDescription": "A short personalized explanation of why their music matches this vibe and food.",
          "mainMeal": {
            "title": "Dish name",
            "price": "Rp 25.000",
            "location": "Dummy restaurant name",
            "calories": "600 kcal",
            "description": "Appetizing description of the food",
            "systemImage": "flame.fill",
            "gradientColors": ["orange", "red"]
          },
          "alternatives": [
            {
              "title": "Dish name 2",
              "price": "Rp 20.000",
              "location": "Dummy restaurant 2",
              "calories": "500 kcal",
              "description": "Appetizing description",
              "systemImage": "leaf.fill",
              "gradientColors": ["green", "teal"]
            }
          ]
        }
        """
        
        let session = LanguageModelSession(model: SystemLanguageModel(useCase: .general))
        let response = try await session.respond(to: promptText)
        let jsonText = response.content
        
        let cleanJSON = jsonText.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
        
        guard let data = cleanJSON.data(using: .utf8) else {
            throw URLError(.cannotDecodeRawData)
        }
        
        let result = try JSONDecoder().decode(AIResponse.self, from: data)
        
        let mainMeal = Meal(
            title: result.mainMeal.title,
            price: result.mainMeal.price,
            location: result.mainMeal.location,
            calories: result.mainMeal.calories,
            description: result.mainMeal.description,
            systemImage: result.mainMeal.systemImage,
            gradientColors: result.mainMeal.gradientColors
        )
        
        let alternatives = result.alternatives.map {
            Meal(
                title: $0.title,
                price: $0.price,
                location: $0.location,
                calories: $0.calories,
                description: $0.description,
                systemImage: $0.systemImage,
                gradientColors: $0.gradientColors
            )
        }
        
        return (result.vibeName, result.vibeDescription, mainMeal, alternatives)
    }
}

