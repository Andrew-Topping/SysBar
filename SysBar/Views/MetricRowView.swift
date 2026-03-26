import SwiftUI

/// A single labelled progress bar row (CPU, RAM, Disk, etc.)
struct MetricRowView: View {
    let label: String
    let fraction: Double       // 0.0–1.0
    let valueText: String

    private var barColor: Color {
        switch fraction {
        case ..<0.6:  return Color(hex: "#00ff88")  // green
        case ..<0.85: return Color(hex: "#ffcc00")  // yellow
        default:      return Color(hex: "#ff4444")  // red
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.gray)
                .frame(width: 36, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(barColor)
                        .frame(width: geo.size.width * CGFloat(max(0, min(fraction, 1))), height: 8)
                }
                .frame(height: geo.size.height, alignment: .center)
            }
            .frame(height: 16)

            Text(valueText)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(Color(hex: "#e0e0e0"))
                .frame(width: 72, alignment: .trailing)
        }
    }
}
