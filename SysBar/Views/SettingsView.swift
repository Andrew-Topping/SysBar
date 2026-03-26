import SwiftUI

/// Milestone 5 — placeholder for settings panel.
struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings")
                .font(.system(.headline, design: .monospaced))
                .foregroundColor(.white)
            Text("Coming in v1.1")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.gray)
        }
        .frame(width: 280, height: 160)
        .background(Color(hex: "#1a1a1a"))
    }
}
