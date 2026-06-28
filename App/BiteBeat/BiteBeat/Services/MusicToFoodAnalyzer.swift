import Foundation
import BiteBeatMusic
import SwiftUI
import FoundationModels

// Data model for a recommended meal
public struct Meal: Identifiable, Hashable, Codable, Sendable {
    public let id: UUID
    public let title: String
    public let price: String
    public let location: String
    public let calories: String
    public let description: String
    public let systemImage: String
    public let gradientColors: [String] // Color name strings for generating SwiftUI gradients
    public let imageUrl: String
    public let imageQuery: String
    public let crazyFunDescription: String

    nonisolated public static let defaultCrazyFunDescription = "Warning - this meal may trigger spontaneous shoulder dancing."

    nonisolated public init(
        title: String,
        price: String,
        location: String,
        calories: String,
        description: String,
        crazyFunDescription: String = Meal.defaultCrazyFunDescription,
        systemImage: String,
        gradientColors: [String],
        imageUrl: String = "",
        imageQuery: String = ""
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
        self.imageQuery = imageQuery
        self.crazyFunDescription = crazyFunDescription
    }

    // Keyword used to look up a photo of the dish itself (not the restaurant).
    public var photoSearchQuery: String {
        imageQuery.isEmpty ? title : imageQuery
    }
    
    // Cleans up any trailing distance labels from the restaurant location
    public var restaurantName: String {
        if let index = location.firstIndex(of: "(") {
            return String(location[..<index]).trimmingCharacters(in: .whitespaces)
        }
        return location
    }
    
    // Converts color name strings into SwiftUI Color instances
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
    let crazyFunDescription: String?
    let systemImage: String
    let gradientColors: [String]
    let imageQuery: String?
}

public enum AnalyzerLanguage: String, Sendable {
    case indonesian = "Indonesian"
    case english = "English"
}

public struct FoodPlaceInfo: Codable, Sendable {
    public let name: String
    public let address: String
    public let distance: String
    public let category: String
}

public enum AnalyzerMode: Sendable {
    case creative
    case database(places: [FoodPlaceInfo])
}

@available(iOS 26.0, *)
public final class MusicToFoodAnalyzer: Sendable {
    public let language: AnalyzerLanguage
    public let mode: AnalyzerMode
    
    public init(language: AnalyzerLanguage = .english, mode: AnalyzerMode = .creative) {
        self.language = language
        self.mode = mode
    }
    
    /// Reads the user's preferred prompt language from UserDefaults.
    public static func storedLanguage() -> AnalyzerLanguage {
        let stored = UserDefaults.standard.string(forKey: "analyzerLanguage") ?? "english"
        return stored == "indonesian" ? .indonesian : .english
    }

    /// Creates a creative-mode analyzer using the stored language preference.
    public static func makeDefault() -> MusicToFoodAnalyzer {
        MusicToFoodAnalyzer(language: storedLanguage(), mode: .creative)
    }
    
    /// Main analysis function that translates tracks into food recommendations (one main, two alternatives) using Apple Intelligence.
    public func analyze(songs: [BiteMusicTrack]) async throws -> (vibeName: String, vibeDescription: String, mainMeal: Meal, alternatives: [Meal]) {
        let dominantGenres = extractDominantGenres(from: songs)
        let songsList = songs.isEmpty ? "No recent songs, default to soft and calming music." : songs.map { "- \($0.title) by \($0.artistName) (Genres: \($0.genreNames.joined(separator: ", ")))" }.joined(separator: "\n")
        
        var promptText = """
        You are a food and music expert. Analyze the following PLAYLIST ANALYSIS and recommend 3 food dishes (1 main, 2 alternatives) that perfectly match the emotional and sonic vibe of the playlist.
        The output (vibeName, vibeDescription, title, and description) MUST be in \(language.rawValue) language.
        
        CRITICAL RULE: You MUST NOT recommend any starch-based street foods (berbahan dasar aci) such as Seblak, Batagor, Siomay, Pempek, Cireng, Cilok, etc. You also MUST NOT recommend any meatballs (Bakso) under any circumstances. Focus on rich and satisfying standard meals or wholesome dishes instead.
        
        PLAYLIST ANALYSIS:
        - Dominant Genres: \(dominantGenres)
        - Track List:
        \(songsList)
        
        DESCRIPTIONS STYLE RULE:
        For each recommended meal, the 'description' field MUST be a highly personalized, creative, and emotionally resonant explanation written in \(language.rawValue). DO NOT map one food to just one song. Instead, treat the ENTIRE playlist as a single emotional journey. The food recommendation must synthesize the overall vibe of MULTIPLE songs together.
        
        Crucially, inside the description, you MUST explicitly mention SEVERAL different song titles and artists from the provided song list to explain how they collectively inspire this dish. Furthermore, use your foundation model knowledge to INFER and QUOTE 1-2 lines of actual famous lyrics from these specific songs to explain the mood and vibe. 
        
        Example narrative structure:
        "This dish is the perfect culinary match for your entire playlist's [Vibe/Mood, e.g., sad/chill] atmosphere, guided by dominant genres like \(dominantGenres). Just as '[Song Title 1]' by [Artist 1] brings a feeling of [emotion], and '[Song Title 2]' by [Artist 2] adds a touch of [emotion]—especially with lyrics like '[Quote actual lyrics]'—this food combines [Food Characteristic 1] and [Food Characteristic 2] to [cheer you up / help you embrace the mood]."
        
        Be highly creative and empathetic. Synthesize the multiple songs into a cohesive culinary story. Do not just use a dry recipe description.
        """
        
        switch mode {
        case .creative:
            promptText += "\n\nYou are free to recommend any suitable Indonesian food."
        case .database(let places):
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let placesJSON = (try? encoder.encode(places)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
            promptText += """


            CRITICAL INSTRUCTION: You MUST recommend food available at real restaurants from the NEARBY RESTAURANTS list below. The 'location' field in your JSON output MUST be the EXACT 'name' of a restaurant from this list — do NOT invent restaurants. This app helps the user grab lunch nearby before getting back to work, so PRIORITIZE restaurants with "category": "nearby" (within 500m) over "others", using 'distance' to decide. For each recommended meal, the 'title' must be a dish that this kind of restaurant realistically serves, and estimate the 'calories' yourself (e.g. "500 kcal").
            NEARBY RESTAURANTS:
            \(placesJSON)
            """
        }
        
        promptText += """
        

        Respond EXACTLY in this JSON format without any markdown blocks or extra text, providing exactly 1 main meal and exactly 2 alternative meals:
        {
          "vibeName": "Short vibe name (e.g. Vibrant & Spicy)",
          "vibeDescription": "A short personalized explanation of why their music matches this vibe and food.",
          "mainMeal": {
            "title": "Dish name",
            "price": "Rp 25.000",
            "location": "Dummy restaurant name",
            "calories": "600 kcal",
            "description": "Appetizing description of the food",
            "crazyFunDescription": "Crazy fun fact about the food",
            "systemImage": "flame.fill",
            "gradientColors": ["orange", "red"],
            "imageQuery": "simple generic name of the dish in English for a stock photo search, e.g. fried rice"
          },
          "alternatives": [
            {
              "title": "Dish name 2",
              "price": "Rp 20.000",
              "location": "Dummy restaurant 2",
              "calories": "500 kcal",
              "description": "Appetizing description",
              "crazyFunDescription": "Crazy fun fact about the food",
              "systemImage": "leaf.fill",
              "gradientColors": ["green", "teal"],
              "imageQuery": "english dish keyword for photo, e.g. meatball soup"
            },
            {
              "title": "Dish name 3",
              "price": "Rp 15.000",
              "location": "Dummy restaurant 3",
              "calories": "400 kcal",
              "description": "Appetizing description",
              "crazyFunDescription": "Crazy fun fact about the food",
              "systemImage": "star.fill",
              "gradientColors": ["purple", "pink"],
              "imageQuery": "english dish keyword for photo, e.g. grilled chicken"
            }
          ]
        }

        For "imageQuery": give the plain, generic dish name in English (no restaurant name, no adjectives) so a stock photo of THAT food can be found. Examples: "fried rice", "meatball soup", "beef noodle soup", "grilled chicken".
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
            crazyFunDescription: result.mainMeal.crazyFunDescription ?? Meal.defaultCrazyFunDescription,
            systemImage: result.mainMeal.systemImage,
            gradientColors: result.mainMeal.gradientColors,
            imageQuery: result.mainMeal.imageQuery ?? ""
        )

        let alternatives = result.alternatives.map {
            Meal(
                title: $0.title,
                price: $0.price,
                location: $0.location,
                calories: $0.calories,
                description: $0.description,
                crazyFunDescription: $0.crazyFunDescription ?? Meal.defaultCrazyFunDescription,
                systemImage: $0.systemImage,
                gradientColors: $0.gradientColors,
                imageQuery: $0.imageQuery ?? ""
            )
        }
        
        return (result.vibeName, result.vibeDescription, mainMeal, alternatives)
    }
    
    private func extractDominantGenres(from songs: [BiteMusicTrack]) -> String {
        var genreCounts: [String: Int] = [:]
        for song in songs {
            for genre in song.genreNames {
                genreCounts[genre, default: 0] += 1
            }
        }
        
        let sortedGenres = genreCounts.sorted { $0.value > $1.value }
        let topGenres = sortedGenres.prefix(3).map { $0.key }
        
        if topGenres.isEmpty {
            return "Mixed / Unknown Vibe"
        } else {
            return topGenres.joined(separator: ", ")
        }
    }
}

