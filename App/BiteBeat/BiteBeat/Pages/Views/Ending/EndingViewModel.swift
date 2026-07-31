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
    public var enjoymentGreeting = "Enjoy Your Meal!"

    private let celebrationSoundPlayer = CelebrationSoundPlayer()
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
        DailyMealSelectionStore.save(selectedMeal)
        celebrationSoundPlayer.play()

        if let randomGreeting = greetings.randomElement() {
            enjoymentGreeting = randomGreeting
        }
    }

    public func handleOnDisappear() {
        celebrationSoundPlayer.stop()
    }
}
