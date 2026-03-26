import Foundation
import Combine

/// Persists user preferences and publishes changes to the SwiftUI view hierarchy.
class AppSettings: ObservableObject {
    @Published var refreshInterval: Double {
        didSet { UserDefaults.standard.set(refreshInterval, forKey: Keys.refreshInterval) }
    }
    @Published var theme: Theme {
        didSet { UserDefaults.standard.set(theme.rawValue, forKey: Keys.theme) }
    }
    @Published var showTextInMenuBar: Bool {
        didSet { UserDefaults.standard.set(showTextInMenuBar, forKey: Keys.showText) }
    }

    init() {
        let stored = UserDefaults.standard.double(forKey: Keys.refreshInterval)
        self.refreshInterval = stored > 0 ? stored : 2.0

        let rawTheme = UserDefaults.standard.string(forKey: Keys.theme) ?? ""
        self.theme = Theme(rawValue: rawTheme) ?? .terminal

        let storedShow = UserDefaults.standard.object(forKey: Keys.showText) as? Bool
        self.showTextInMenuBar = storedShow ?? true
    }

    static let refreshOptions: [Double] = [1, 2, 5, 10]

    private enum Keys {
        static let refreshInterval = "refreshInterval"
        static let theme           = "theme"
        static let showText        = "showTextInMenuBar"
    }
}
