import SwiftUI

extension Color {
    /// Initialise a Color from a hex string like "#1a1a1a" or "1a1a1a".
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&value)
        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >>  8) & 0xFF) / 255.0
        let b = Double( value        & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
