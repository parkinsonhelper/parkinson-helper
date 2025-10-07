
import SwiftUI

enum TabItem: String {
    case home = "Home"
    case history = "History"
    case support = "Support"
    case settings = "Settings"
    
    var localizedString: String {
        switch self {
        case .home: String(localized: "Home")
        case .history: String(localized: "History")
        case .support: String(localized: "Support")
        case .settings: String(localized: "Settings")
        }
    }
    
    var sfSymbol: String {
        switch self {
        case .home: "house.fill"
        case .history: "chart.bar.fill"
        case .support: "person.2.fill"
        case .settings: "gearshape.fill"
        }
    }
}
