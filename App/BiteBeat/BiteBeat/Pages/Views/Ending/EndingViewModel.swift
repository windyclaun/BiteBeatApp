//
//  EndingViewModel.swift
//  BiteBeat
//

import SwiftUI
import Observation
import BiteBeatMusic

@Observable
@MainActor
public final class EndingViewModel {
    public let selectedMeal: Meal
    public var animateSteps = false
    public var enjoymentGreeting = "Selamat Makan! 🇮🇩"

    private let greetings = [
        "Selamat Makan! 🇮🇩",
        "Bon Appétit! 🇫🇷",
        "Itadakimasu! 🇯🇵",
        "Buon Appetito! 🇮🇹",
        "¡Buen Provecho! 🇪🇸",
        "Guten Appetit! 🇩🇪",
        "Enjoy Your Meal! 🇬🇧",
        "Mas-issge Deuseyo! 🇰🇷",
        "Bom Apetite! 🇵🇹",
        "Afiyet Olsun! 🇹🇷"
    ]

    public init(selectedMeal: Meal) {
        self.selectedMeal = selectedMeal
    }

    public func handleOnAppear() {
        if let randomGreeting = greetings.randomElement() {
            enjoymentGreeting = randomGreeting
        }
    }
}
