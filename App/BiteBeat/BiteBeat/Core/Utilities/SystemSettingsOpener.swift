import UIKit

public enum SystemSettingsOpener {
    public static func open() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }

    public static func openAppleIntelligenceSettings() {
        open()
    }
}
