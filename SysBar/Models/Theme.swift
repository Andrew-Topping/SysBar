import SwiftUI

enum Theme: String, CaseIterable, Identifiable {
    case terminal = "terminal"   // green-on-black, htop aesthetic
    case native   = "native"     // macOS system colours
    case ocean    = "ocean"      // blue/teal dark theme

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .terminal: return "Terminal"
        case .native:   return "Native"
        case .ocean:    return "Ocean"
        }
    }

    // MARK: - Surface colours

    var background: Color {
        switch self {
        case .terminal: return Color(hex: "#1a1a1a")
        case .native:   return Color(NSColor.windowBackgroundColor)
        case .ocean:    return Color(hex: "#0d1b2a")
        }
    }

    var headerBackground: Color {
        switch self {
        case .terminal: return Color(hex: "#222222")
        case .native:   return Color(NSColor.controlBackgroundColor)
        case .ocean:    return Color(hex: "#1b2838")
        }
    }

    var titleColor: Color {
        switch self {
        case .terminal: return .white
        case .native:   return Color(NSColor.labelColor)
        case .ocean:    return Color(hex: "#e8f4fd")
        }
    }

    var labelColor: Color {
        switch self {
        case .terminal: return .gray
        case .native:   return Color(NSColor.secondaryLabelColor)
        case .ocean:    return Color(hex: "#6b9ab8")
        }
    }

    var valueColor: Color {
        switch self {
        case .terminal: return Color(hex: "#e0e0e0")
        case .native:   return Color(NSColor.labelColor)
        case .ocean:    return Color(hex: "#c8d8e8")
        }
    }

    var trackColor: Color {
        switch self {
        case .terminal: return Color.white.opacity(0.08)
        case .native:   return Color(NSColor.separatorColor).opacity(0.4)
        case .ocean:    return Color.white.opacity(0.08)
        }
    }

    // MARK: - Bar colour by usage level

    func barColor(for fraction: Double) -> Color {
        switch self {
        case .terminal:
            switch fraction {
            case ..<0.6:  return Color(hex: "#00ff88")
            case ..<0.85: return Color(hex: "#ffcc00")
            default:      return Color(hex: "#ff4444")
            }
        case .native:
            switch fraction {
            case ..<0.6:  return .green
            case ..<0.85: return .yellow
            default:      return .red
            }
        case .ocean:
            switch fraction {
            case ..<0.6:  return Color(hex: "#00b4d8")
            case ..<0.85: return Color(hex: "#f77f00")
            default:      return Color(hex: "#e63946")
            }
        }
    }
}
