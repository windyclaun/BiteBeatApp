import Foundation

public struct FoodPreferences: Codable, Equatable, Sendable, RawRepresentable {
    public var diet: Diet
    public var cuisine: Cuisine
    public var maxBudget: Budget
    public var allergens: Set<Allergen>
    public var preferredMoods: Set<MoodTag>

    public init(
        diet: Diet = .noRestriction,
        cuisine: Cuisine = .any,
        maxBudget: Budget = .medium,
        allergens: Set<Allergen> = [],
        preferredMoods: Set<MoodTag> = []
    ) {
        self.diet = diet
        self.cuisine = cuisine
        self.maxBudget = maxBudget
        self.allergens = allergens
        self.preferredMoods = preferredMoods
    }

    public static let `default` = FoodPreferences()

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let json = String(data: data, encoding: .utf8) else {
            return ""
        }
        return json
    }

    public init?(rawValue: String) {
        guard !rawValue.isEmpty,
              let data = rawValue.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(FoodPreferences.self, from: data) else {
            return nil
        }
        self = decoded
    }

    public var hasActivePreferences: Bool {
        diet != .noRestriction
            || cuisine != .any
            || maxBudget != .medium
            || !allergens.isEmpty
            || !preferredMoods.isEmpty
    }

    public func filterPromptBlock() -> String {
        guard hasActivePreferences else { return "" }

        var lines: [String] = []
        lines.append("\n\nUSER FOOD PREFERENCES — respect these constraints strictly:")
        if diet != .noRestriction {
            lines.append("- Diet: \(diet.rawValue). Recommended dishes MUST comply with this diet.")
        }
        if cuisine != .any {
            lines.append("- Preferred cuisine: \(cuisine.rawValue). Favor dishes matching this cuisine.")
        }
        if maxBudget != .medium {
            lines.append("- Budget level: \(maxBudget.rawValue) (low ≈ under Rp 20.000, medium ≈ Rp 20.000–Rp 40.000, high ≈ above Rp 40.000). Keep suggested price within this range.")
        }
        if !allergens.isEmpty {
            let names = allergens.map(\.rawValue).sorted().joined(separator: ", ")
            lines.append("- Allergens to AVOID: \(names). MUST NOT recommend dishes containing these.")
        }
        if !preferredMoods.isEmpty {
            let names = preferredMoods.map(\.rawValue).sorted().joined(separator: ", ")
            lines.append("- Preferred flavor moods: \(names). Lean toward dishes matching these vibe-moods.")
        }
        lines.append("- If a constraint conflicts with a dish from the database, pick a different dish that fits.")
        return lines.joined(separator: "\n")
    }
}

public extension FoodPreferences {
    static let appStorageKey = "foodPreferences"

    static func current() -> FoodPreferences {
        if let raw = UserDefaults.standard.string(forKey: appStorageKey) {
            return FoodPreferences(rawValue: raw) ?? .default
        }
        return .default
    }
}

public extension FoodPreferences {
    enum Diet: String, Codable, CaseIterable, Identifiable, Sendable {
        case noRestriction = "No Restriction"
        case vegetarian = "Vegetarian"
        case vegan = "Vegan"
        case pescatarian = "Pescatarian"
        case halal = "Halal"
        case glutenFree = "Gluten-Free"

        public var id: String { rawValue }
        public var systemImage: String {
            switch self {
            case .noRestriction: return "fork.knife"
            case .vegetarian: return "leaf"
            case .vegan: return "leaf.fill"
            case .pescatarian: return "fish"
            case .halal: return "checkmark.seal"
            case .glutenFree: return "dot.radiowaves.left.and.right"
            }
        }
    }

    enum Cuisine: String, Codable, CaseIterable, Identifiable, Sendable {
        case any = "Any Cuisine"
        case indonesian = "Indonesian"
        case asian = "Asian"
        case western = "Western"
        case mediterranean = "Mediterranean"
        case japanese = "Japanese"
        case korean = "Korean"
        case middleEastern = "Middle Eastern"

        public var id: String { rawValue }
        public var systemImage: String {
            switch self {
            case .any: return "globe"
            case .indonesian: return "cup.and.saucer.fill"
            case .asian: return "takeoutbag.and.cup.and.straw.fill"
            case .western: return "fork.knife.circle"
            case .mediterranean: return "person.2.fill"
            case .japanese: return "fish.fill"
            case .korean: return "flame.fill"
            case .middleEastern: return "leaf.circle.fill"
            }
        }
    }

    enum Budget: String, Codable, CaseIterable, Identifiable, Sendable {
        case low = "Budget (under Rp 20k)"
        case medium = "Standard (Rp 20k–40k)"
        case high = "Premium (above Rp 40k)"

        public var id: String { rawValue }
        public var systemImage: String {
            switch self {
            case .low: return "tag"
            case .medium: return "tag.fill"
            case .high: return "crown"
            }
        }
    }

    enum Allergen: String, Codable, CaseIterable, Identifiable, Sendable {
        case peanut = "Peanut"
        case shellfish = "Shellfish"
        case dairy = "Dairy"
        case egg = "Egg"
        case gluten = "Gluten"
        case soy = "Soy"
        case fish = "Fish"
        case nuts = "Tree Nuts"
        case sesame = "Sesame"

        public var id: String { rawValue }
        public var systemImage: String {
            switch self {
            case .peanut: return "circle.hexagonpath"
            case .shellfish: return "fish.fill"
            case .dairy: return "drop.halffull"
            case .egg: return "circle"
            case .gluten: return "leaf"
            case .soy: return "circle.dashed"
            case .fish: return "fish"
            case .nuts: return "circle.grid.cross"
            case .sesame: return "circle.grid.cross.fill"
            }
        }
    }

    enum MoodTag: String, Codable, CaseIterable, Identifiable, Sendable {
        case spicy = "Spicy"
        case sweet = "Sweet"
        case savory = "Savory"
        case fresh = "Fresh & Light"
        case comfort = "Comfort"
        case bold = "Bold"

        public var id: String { rawValue }
        public var systemImage: String {
            switch self {
            case .spicy: return "flame"
            case .sweet: return "birthday.cake.fill"
            case .savory: return "bolt"
            case .fresh: return "leaf"
            case .comfort: return "heart"
            case .bold: return "bold"
            }
        }
        public var shortLabel: String { rawValue }
    }
}