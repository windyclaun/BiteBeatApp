//
//  RecommendationViewModel.swift
//  BiteBeat
//

import SwiftUI
import Observation
import BiteBeatMusic

@Observable
@MainActor
public final class RecommendationViewModel {
    public let vibeName: String
    public let mainMeal: Meal
    public let alternatives: [Meal]
    
    public var choseNay = false
    public var selectedAlternative: Meal?
    public var navigateToEnding = false
    public var finalMeal: Meal?
    
    public init(vibeName: String, mainMeal: Meal, alternatives: [Meal]) {
        self.vibeName = vibeName
        self.mainMeal = mainMeal
        self.alternatives = alternatives
    }
    
    public func selectMainMeal() {
        finalMeal = mainMeal
        navigateToEnding = true
    }
    
    public func selectAlternativeMeal() {
        if let selectedAlternative {
            finalMeal = selectedAlternative
            navigateToEnding = true
        }
    }
    
    public func toggleShowAlternatives(show: Bool) {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
            choseNay = show
            if !show {
                selectedAlternative = nil
            }
        }
    }
    
    public func selectAlternativeCard(_ meal: Meal) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
            selectedAlternative = meal
        }
    }
    
    public func resetToMainSelection() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.7)) {
            choseNay = false
            selectedAlternative = nil
        }
    }
}
