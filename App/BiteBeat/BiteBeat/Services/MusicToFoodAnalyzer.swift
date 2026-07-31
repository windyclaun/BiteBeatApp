import Foundation
import CoreLocation
import BiteBeatMusic
import SwiftUI
import FoundationModels

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
}

fileprivate struct AIResponseRestaurants: Codable {
    let vibeName: String
    let vibeDescription: String
    let restaurants: [AIRestaurantDishes]
}

fileprivate struct AIRestaurantDishes: Codable {
    let name: String
    let dishes: [AIMeal]
}

public enum AnalyzerLanguage: String, Sendable {
    case indonesian = "Indonesian"
    case english = "English"
}

public final class MusicToFoodAnalyzer: Sendable {
    public let language: AnalyzerLanguage

    public init(language: AnalyzerLanguage = .english) {
        self.language = language
    }

    /// Creates a MusicToFoodAnalyzer using the user's language preference and AI-driven creative mode.
    public static func makeDefault() -> MusicToFoodAnalyzer {
        let storedLanguage = UserDefaults.standard.string(forKey: "analyzerLanguage") ?? "english"
        let language: AnalyzerLanguage = (storedLanguage == "indonesian") ? .indonesian : .english
        return MusicToFoodAnalyzer(language: language)
    }
    
    /// Main analysis function that translates tracks into food recommendations (one main, two alternatives) using Apple Intelligence.
    public func analyze(songs: [BiteMusicTrack]) async throws -> (vibeName: String, vibeDescription: String, mainMeal: Meal, alternatives: [Meal]) {
        let dominantGenres = extractDominantGenres(from: songs)
        let songsList = songs.isEmpty ? "No recent songs, default to soft and calming music." : songs.map { "- \($0.title) by \($0.artistName) (Genres: \($0.genreNames.joined(separator: ", ")))" }.joined(separator: "\n")
        
        var promptText = """
        You are a food and music expert. Analyze the following PLAYLIST ANALYSIS and recommend 3 food dishes (1 main, 2 alternatives) that perfectly match the emotional and sonic vibe of the playlist.
        The output (vibeName, vibeDescription, title, and description) MUST be in \(language.rawValue) language.
        
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
        promptText += FoodPreferences.current().filterPromptBlock()

        promptText += """


        You are free to recommend any suitable Indonesian food that matches the vibe. Do not be constrained by a fixed list.

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
            "crazyFunDescription": "Crazy fun fact about the food"
          },
          "alternatives": [
            {
              "title": "Dish name 2",
              "price": "Rp 20.000",
              "location": "Dummy restaurant 2",
              "calories": "500 kcal",
              "description": "Appetizing description",
              "crazyFunDescription": "Crazy fun fact about the food"
            },
            {
              "title": "Dish name 3",
              "price": "Rp 15.000",
              "location": "Dummy restaurant 3",
              "calories": "400 kcal",
              "description": "Appetizing description",
              "crazyFunDescription": "Crazy fun fact about the food"
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
            crazyFunDescription: result.mainMeal.crazyFunDescription ?? Meal.defaultCrazyFunDescription
        )

        let alternatives = result.alternatives.map {
            Meal(
                title: $0.title,
                price: $0.price,
                location: $0.location,
                calories: $0.calories,
                description: $0.description,
                crazyFunDescription: $0.crazyFunDescription ?? Meal.defaultCrazyFunDescription
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

    public func analyze(
        songs: [BiteMusicTrack],
        nearbyRestaurants: [NearbyRestaurant]
    ) async throws -> (vibeName: String, vibeDescription: String, restaurants: [RestaurantDishes]) {
        let dominantGenres = extractDominantGenres(from: songs)
        let songsList = songs.isEmpty
            ? "No recent songs, default to soft and calming music."
            : songs.map { "- \($0.title) by \($0.artistName) (Genres: \($0.genreNames.joined(separator: ", ")))" }.joined(separator: "\n")

        let restaurantList = nearbyRestaurants.enumerated().map { index, r in
            let distStr = r.distanceInMeters < 1000
                ? String(format: "%.0fm", r.distanceInMeters)
                : String(format: "%.1fkm", r.distanceInMeters / 1000)
            return "Restaurant \(index + 1): \(r.name) (\(distStr) away)"
        }.joined(separator: "\n")

        var promptText = """
        You are a food and music expert. The user is near the following REAL restaurants. For EACH restaurant, suggest 3 dishes that the restaurant would plausibly serve, matched to the user's music vibe.
        The output (vibeName, vibeDescription, title, description) MUST be in \(language.rawValue) language.

        NEARBY REAL RESTAURANTS:
        \(restaurantList)

        PLAYLIST ANALYSIS:
        - Dominant Genres: \(dominantGenres)
        - Track List:
        \(songsList)

        DISH SUGGESTION RULES:
        - Each restaurant's dishes MUST match what that type of restaurant would plausibly serve. Infer the cuisine type from the restaurant name.
        - The vibe of the music should influence dish SELECTION (e.g. upbeat music → bold/spicy dishes, chill music → comfort food).
        - Label your suggestions as "Menu suggested by AI", NOT literal menus.

        DESCRIPTIONS STYLE RULE:
        For each recommended meal, the 'description' field MUST be a highly personalized, creative, and emotionally resonant explanation written in \(language.rawValue). Mention SEVERAL song titles and artists from the playlist. INFER and QUOTE 1-2 famous lyrics to explain the mood.
        """
        promptText += FoodPreferences.current().filterPromptBlock()

        promptText += """


        You are free to recommend any suitable dishes for each restaurant. Do not be constrained by a fixed list.

        Respond EXACTLY in this JSON format without any markdown blocks or extra text. Provide exactly \(nearbyRestaurants.count) restaurants with 3 dishes each:
        {
          "vibeName": "Short vibe name (e.g. Vibrant & Spicy)",
          "vibeDescription": "A short explanation of the music vibe and food connection.",
          "restaurants": [
            {
              "name": "\(nearbyRestaurants.first?.name ?? "Restaurant 1")",
              "dishes": [
                {
                  "title": "Dish name",
                  "price": "Rp 25.000",
                  "location": "Same as restaurant name",
                  "calories": "600 kcal",
                  "description": "Creative description referencing songs and lyrics",
                  "crazyFunDescription": "Fun fact about the dish"
                }
              ]
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

        let result = try JSONDecoder().decode(AIResponseRestaurants.self, from: data)

        var matched: [RestaurantDishes] = []
        var usedIndices = Set<Int>()

        for aiRestaurant in result.restaurants {
            let normalizedName = aiRestaurant.name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

            if let idx = nearbyRestaurants.enumerated().first(where: { _, r in
                r.name.lowercased().contains(normalizedName) || normalizedName.contains(r.name.lowercased())
            })?.offset, !usedIndices.contains(idx) {
                usedIndices.insert(idx)
                let meals = aiRestaurant.dishes.map { aiMeal in
                    Meal(
                        title: aiMeal.title,
                        price: aiMeal.price,
                        location: nearbyRestaurants[idx].name,
                        calories: aiMeal.calories,
                        description: aiMeal.description,
                        crazyFunDescription: aiMeal.crazyFunDescription ?? Meal.defaultCrazyFunDescription,
                        realRestaurantName: nearbyRestaurants[idx].name,
                        restaurantAddress: nearbyRestaurants[idx].address,
                        latitude: nearbyRestaurants[idx].coordinate.latitude,
                        longitude: nearbyRestaurants[idx].coordinate.longitude,
                        distanceInMeters: nearbyRestaurants[idx].distanceInMeters,
                        mapItemIdentifier: nearbyRestaurants[idx].mapItemIdentifier
                    )
                }
                matched.append(RestaurantDishes(restaurant: nearbyRestaurants[idx], dishes: meals))
            }
        }

        if matched.count < nearbyRestaurants.count {
            for (idx, restaurant) in nearbyRestaurants.enumerated() where !usedIndices.contains(idx) {
                let aiIdx = matched.count
                let aiRestaurant = result.restaurants.indices.contains(aiIdx) ? result.restaurants[aiIdx] : nil
                let meals = (aiRestaurant?.dishes ?? []).map { aiMeal in
                    Meal(
                        title: aiMeal.title,
                        price: aiMeal.price,
                        location: restaurant.name,
                        calories: aiMeal.calories,
                        description: aiMeal.description,
                        crazyFunDescription: aiMeal.crazyFunDescription ?? Meal.defaultCrazyFunDescription,
                        realRestaurantName: restaurant.name,
                        restaurantAddress: restaurant.address,
                        latitude: restaurant.coordinate.latitude,
                        longitude: restaurant.coordinate.longitude,
                        distanceInMeters: restaurant.distanceInMeters,
                        mapItemIdentifier: restaurant.mapItemIdentifier
                    )
                }
                matched.append(RestaurantDishes(restaurant: restaurant, dishes: meals))
            }
        }

        return (result.vibeName, result.vibeDescription, matched)
    }
}

