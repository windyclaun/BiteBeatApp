//
//  MusicToFoodAnalyzer.swift
//  BiteBeat
//

import Foundation
import MusicKit
import SwiftUI
// MMM



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
        switch title {
        case "Nasi Uduk Ayam Goreng": return "Nasi uduk"
        case "Sate Ayam Madura": return "Sate"
        case "Nasi Goreng Gila": return "Nasi goreng"
        case "Bubur Ayam Kuning": return "Bubur ayam"
        case "Sop Ayam Kampung": return "Sop"
        case "Soto Betawi Kuah Susu": return "Soto Betawi"
        case "Martabak Cokelat Keju": return "Martabak"
        case "Pisang Goreng Madu": return "Pisang goreng"
        case "Roti Bakar Bandung": return "Roti bakar"
        case "Gado-Gado Siram": return "Gado-gado"
        case "Ketoprak Jakarta": return "Ketoprak"
        case "Pecel Madiun": return "Nasi pecel"
        case "Nasi Padang Rendang": return "Rendang"
        case "Iga Bakar Madu": return "Iga penyet"
        case "Mie Goreng Jawa Nyemek": return "Mie goreng"
        default: return title
        }
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
    
    // Fungsi utama buat nerjemahin list lagu ke vibe makanan (dapat menu utama & 2 alternatif)
    public func analyze(songs: [Song]) -> (vibe: MusicVibe, mainMeal: Meal, alternatives: [Meal]) {
        let vibe = determineVibe(from: songs)
        let meals = getMeals(for: vibe)
        return (vibe, meals.main, meals.alternatives)
    }
    
    // Nyari vibe dominan dari genre & kata kunci list lagu
    private func determineVibe(from songs: [Song]) -> MusicVibe {
        guard !songs.isEmpty else {
            // Kalo riwayat lagu kosong, default ke makanan anget
            return .comfortingWarm
        }
        
        var vibrantScore = 0
        var comfortingScore = 0
        var indulgentScore = 0
        var cleanScore = 0
        var boldScore = 0
        
        for song in songs {
            // 1. Cek genre lagu kalo tersedia di MusicKit
            if let genres = song.genres {
                for genre in genres {
                    let name = genre.name.lowercased()
                    if name.contains("pop") || name.contains("dance") || name.contains("electronic") || name.contains("latin") {
                        vibrantScore += 3
                    } else if name.contains("jazz") || name.contains("soul") || name.contains("blues") || name.contains("r&b") {
                        comfortingScore += 3
                    } else if name.contains("indie") || name.contains("acoustic") || name.contains("singer") || name.contains("folk") {
                        indulgentScore += 3
                    } else if name.contains("classical") || name.contains("ambient") || name.contains("new age") {
                        cleanScore += 3
                    } else if name.contains("rock") || name.contains("metal") || name.contains("hip-hop") || name.contains("rap") || name.contains("alternative") {
                        boldScore += 3
                    }
                }
            }
            
            // 2. Cek kata kunci di judul lagu atau nama artis
            let content = (song.title + " " + song.artistName).lowercased()
            
            // Cocok buat makanan pedas & rame
            if content.contains("spicy") || content.contains("hot") || content.contains("summer") || content.contains("sun") || content.contains("party") || content.contains("dance") || content.contains("fire") {
                vibrantScore += 2
            }
            // Cocok buat makanan anget & nyaman
            if content.contains("warm") || content.contains("home") || content.contains("night") || content.contains("coffee") || content.contains("slow") || content.contains("quiet") || content.contains("love") {
                comfortingScore += 2
            }
            // Cocok buat yang manis-manis
            if content.contains("sweet") || content.contains("sad") || content.contains("tear") || content.contains("heart") || content.contains("sugar") || content.contains("chocolate") || content.contains("cry") {
                indulgentScore += 2
            }
            // Cocok buat makanan sehat & segar
            if content.contains("fresh") || content.contains("morning") || content.contains("water") || content.contains("clear") || content.contains("green") || content.contains("breeze") || content.contains("peace") {
                cleanScore += 2
            }
            // Cocok buat makanan berat porsi mantap
            if content.contains("heavy") || content.contains("rock") || content.contains("hard") || content.contains("dark") || content.contains("loud") || content.contains("beast") || content.contains("wild") {
                boldScore += 2
            }
        }
        
        // Gabungin dan cari skor tertinggi
        let scores = [
            MusicVibe.vibrantSpicy: vibrantScore,
            MusicVibe.comfortingWarm: comfortingScore,
            MusicVibe.indulgentSweet: indulgentScore,
            MusicVibe.cleanFresh: cleanScore,
            MusicVibe.boldHearty: boldScore
        ]
        
        // Ambil vibe skor tertinggi, kalo semua 0 pake acak terpola dari lagu pertama
        if let maxVibe = scores.max(by: { $0.value < $1.value }), maxVibe.value > 0 {
            return maxVibe.key
        } else {
            // Acak terpola pake hash dari lagu pertama
            let hash = abs(songs.first?.title.hashValue ?? 0)
            let index = hash % MusicVibe.allCases.count
            return MusicVibe.allCases[index]
        }
    }
    
    private func getMeals(for vibe: MusicVibe) -> (main: Meal, alternatives: [Meal]) {
        switch vibe {
        case .vibrantSpicy:
            return (
                main: Meal(
                    title: "Nasi Uduk Ayam Goreng",
                    price: "Rp 25.000",
                    location: "Nasi Uduk Ibu Sum (0.4 km)",
                    calories: "680 kcal",
                    description: "Nasi uduk gurih wangi pandan disajikan hangat pakai ayam goreng kuning renyah, tempe garing, lalapan segar, plus sambal terasi ulek yang pedasnya mantap!",
                    systemImage: "flame.fill",
                    gradientColors: ["orange", "red"],
                    imageUrl: "https://images.unsplash.com/photo-1615887023516-9b6bcd559e87?w=600&auto=format&fit=crop"
                ),
                alternatives: [
                    Meal(
                        title: "Sate Ayam Madura",
                        price: "Rp 28.000",
                        location: "Sate Khas Senayan (0.5 km)",
                        calories: "520 kcal",
                        description: "10 tusuk sate daging ayam pilihan yang empuk dibalur bumbu kacang kental gurih manis khas Madura, lengkap dengan lontong hangat.",
                        systemImage: "fork.knife",
                        gradientColors: ["yellow", "orange"],
                        imageUrl: "https://images.unsplash.com/photo-1529042410759-befb1204b468?w=600&auto=format&fit=crop"
                    ),
                    Meal(
                        title: "Nasi Goreng Gila",
                        price: "Rp 22.000",
                        location: "Nasgor Gila Gondangdia (0.6 km)",
                        calories: "720 kcal",
                        description: "Nasi goreng wangi khas kaki lima yang disajikan super heboh dengan tumisan telur acak, sosis, dan suwiran ayam pedas gurih.",
                        systemImage: "fork.knife",
                        gradientColors: ["red", "pink"],
                        imageUrl: "https://images.unsplash.com/photo-1604382355076-af4b0eb60143?w=600&auto=format&fit=crop"
                    )
                ]
            )
            
        case .comfortingWarm:
            return (
                main: Meal(
                    title: "Bubur Ayam Kuning",
                    price: "Rp 18.000",
                    location: "Bubur Ayam Barito (0.3 km)",
                    calories: "420 kcal",
                    description: "Bubur nasi lembut gurih disiram kuah kuning harum, ditaburi suwiran ayam melimpah, kacang kedelai, seledri, bawang goreng, emping garing, plus sate usus!",
                    systemImage: "sparkles",
                    gradientColors: ["yellow", "orange"],
                    imageUrl: "https://images.unsplash.com/photo-1596797038530-2c107229654b?w=600&auto=format&fit=crop"
                ),
                alternatives: [
                    Meal(
                        title: "Sop Ayam Kampung",
                        price: "Rp 24.000",
                        location: "Sop Ayam Pak Min (0.2 km)",
                        calories: "380 kcal",
                        description: "Kuah sop bening kaldu ayam kampung yang super gurih dan hangat di tenggorokan, lengkap dengan potongan wortel, kentang lembut, dan seledri segar.",
                        systemImage: "fork.knife",
                        gradientColors: ["green", "teal"],
                        imageUrl: "https://images.unsplash.com/photo-1547592165-e1d17fed6006?w=600&auto=format&fit=crop"
                    ),
                    Meal(
                        title: "Soto Betawi Kuah Susu",
                        price: "Rp 35.000",
                        location: "Soto Betawi H. Husein (0.8 km)",
                        calories: "620 kcal",
                        description: "Daging sapi empuk dalam kuah susu santan gurih berempah khas Betawi, lengkap dengan kentang goreng lembut, potongan tomat segar, emping empuk, dan jeruk limo.",
                        systemImage: "fork.knife",
                        gradientColors: ["orange", "red"],
                        imageUrl: "https://images.unsplash.com/photo-1608897013039-887f21d8c804?w=600&auto=format&fit=crop"
                    )
                ]
            )
            
        case .indulgentSweet:
            return (
                main: Meal(
                    title: "Martabak Cokelat Keju",
                    price: "Rp 65.000",
                    location: "Martabak Pecenongan 65 (0.2 km)",
                    calories: "850 kcal",
                    description: "Martabak tebal legit berongga wangi mentega Wijsman super melimpah, ditaburi parutan keju tebal, butiran cokelat meses premium, dan kental manis yang bikin bahagia lahir batin!",
                    systemImage: "heart.fill",
                    gradientColors: ["pink", "purple"],
                    imageUrl: "https://images.unsplash.com/photo-1551024601-bec78aea704b?w=600&auto=format&fit=crop"
                ),
                alternatives: [
                    Meal(
                        title: "Pisang Goreng Madu",
                        price: "Rp 15.000",
                        location: "Pisang Goreng Bu Nanik (0.4 km)",
                        calories: "420 kcal",
                        description: "Pisang raja manis yang digoreng hingga karamelisasi madunya berwarna cokelat gelap garing di luar namun sangat lembut legit di dalam.",
                        systemImage: "fork.knife",
                        gradientColors: ["purple", "blue"],
                        imageUrl: "https://images.unsplash.com/photo-1566843972142-a7fcb70de55a?w=600&auto=format&fit=crop"
                    ),
                    Meal(
                        title: "Roti Bakar Bandung",
                        price: "Rp 20.000",
                        location: "Roti Bakar Eddy (0.5 km)",
                        calories: "550 kcal",
                        description: "Roti bakar empuk beraroma wangi panggangan mentega dengan isian selai cokelat manis dan serutan keju cheddar gurih melimpah.",
                        systemImage: "fork.knife",
                        gradientColors: ["yellow", "orange"],
                        imageUrl: "https://images.unsplash.com/photo-1584776296974-3823445859c2?w=600&auto=format&fit=crop"
                    )
                ]
            )
            
        case .cleanFresh:
            return (
                main: Meal(
                    title: "Gado-Gado Siram",
                    price: "Rp 22.000",
                    location: "Gado-Gado Boplo (0.5 km)",
                    calories: "450 kcal",
                    description: "Rebusan sayur segar pilihan (kacang panjang, tauge, bayam, labu siam) dipadu tahu putih, tempe garing, telur rebus, disiram bumbu kacang mete kental gurih manis wangi limo!",
                    systemImage: "leaf.fill",
                    gradientColors: ["green", "teal"],
                    imageUrl: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&auto=format&fit=crop"
                ),
                alternatives: [
                    Meal(
                        title: "Ketoprak Jakarta",
                        price: "Rp 18.000",
                        location: "Ketoprak Ciragil (0.1 km)",
                        calories: "480 kcal",
                        description: "Irisan ketupat empuk padat, tahu goreng hangat renyah, bihun lembut, tauge segar disiram ulekan bumbu kacang bawang putih cabai rawit gurih manis plus taburan emping.",
                        systemImage: "fork.knife",
                        gradientColors: ["teal", "blue"],
                        imageUrl: "https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600&auto=format&fit=crop"
                    ),
                    Meal(
                        title: "Pecel Madiun",
                        price: "Rp 15.000",
                        location: "Pecel Pincuk Bu Pri (0.3 km)",
                        calories: "390 kcal",
                        description: "Nasi putih hangat dengan kombinasi kangkung, tauge, daun pepaya manis, disiram bumbu pecel pedas gurih harum daun jeruk limo, disajikan dengan peyek kacang renyah.",
                        systemImage: "fork.knife",
                        gradientColors: ["green", "yellow"],
                        imageUrl: "https://images.unsplash.com/photo-1515003848606-ca0597947d65?w=600&auto=format&fit=crop"
                    )
                ]
            )
            
        case .boldHearty:
            return (
                main: Meal(
                    title: "Nasi Padang Rendang",
                    price: "Rp 32.000",
                    location: "RM Sederhana (0.7 km)",
                    calories: "780 kcal",
                    description: "Nasi putih hangat disiram kuah gulai gurih berempah, sayur nangka muda lembut, sambal hijau pedas khas Minang, plus sepotong Rendang Daging Sapi tebal yang bumbunya meresap sempurna!",
                    systemImage: "bolt.fill",
                    gradientColors: ["red", "purple"],
                    imageUrl: "https://images.unsplash.com/photo-1544025162-d76694265947?w=600&auto=format&fit=crop"
                ),
                alternatives: [
                    Meal(
                        title: "Iga Bakar Madu",
                        price: "Rp 48.000",
                        location: "Iga Bakar Jangkung (0.4 km)",
                        calories: "720 kcal",
                        description: "Iga sapi potong tebal yang empuk banget dilepas dari tulangnya, dibakar dengan baluran kecap manis madu premium, disajikan hangat wangi semerbak.",
                        systemImage: "fork.knife",
                        gradientColors: ["orange", "red"],
                        imageUrl: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&auto=format&fit=crop"
                    ),
                    Meal(
                        title: "Mie Goreng Jawa Nyemek",
                        price: "Rp 22.000",
                        location: "Bakmi Jawa Mas Tok (1.2 km)",
                        calories: "680 kcal",
                        description: "Bakmi kuning tebal yang dimasak nyemek berkuah kental sedikit dengan telur bebek acak, suwiran ayam kol sayur segar, rasa manis gurihnya mantap berkarakter!",
                        systemImage: "fork.knife",
                        gradientColors: ["purple", "pink"],
                        imageUrl: "https://images.unsplash.com/photo-1585032226651-759b368d7246?w=600&auto=format&fit=crop"
                    )
                ]
            )
        }
    }
}
