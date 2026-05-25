import Foundation
import FoundationModels

@available(iOS 26.0, *)
public enum AppleIntelligenceHelper {
    public static var isNotEnabled: Bool {
        if case .unavailable(.appleIntelligenceNotEnabled) = SystemLanguageModel.default.availability {
            return true
        }
        return false
    }
}
