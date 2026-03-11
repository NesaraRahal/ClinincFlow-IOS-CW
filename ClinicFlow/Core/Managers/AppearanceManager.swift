import SwiftUI
import Combine

// MARK: - Appearance Manager
// Manages app-wide theme (Light / Dark / System) with persistence
class AppearanceManager: ObservableObject {
    @Published var appearance: String {
        didSet {
            UserDefaults.standard.set(appearance, forKey: "appAppearance")
        }
    }
    
    init() {
        self.appearance = UserDefaults.standard.string(forKey: "appAppearance") ?? "System"
    }
    
    var colorScheme: ColorScheme? {
        switch appearance {
        case "Light": return .light
        case "Dark": return .dark
        default: return nil // System default
        }
    }
}
