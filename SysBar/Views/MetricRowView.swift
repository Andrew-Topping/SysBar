import SwiftUI

/// A single labelled progress bar row (CPU, RAM, Disk, etc.)
struct MetricRowView: View {
    @EnvironmentObject var settings: AppSettings

    let label: String
    let fraction: Double       // 0.0–1.0
    let valueText: String

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(settings.theme.labelColor)
                .frame(width: 36, alignment: .leading)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(settings.theme.trackColor)
                        .frame(height: 8)
                    RoundedRectangle(cornerRadius: 2)
                        .fill(settings.theme.barColor(for: fraction))
                        .frame(width: geo.size.width * CGFloat(max(0, min(fraction, 1))), height: 8)
                }
                .frame(height: geo.size.height, alignment: .center)
            }
            .frame(height: 16)

            Text(valueText)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(settings.theme.valueColor)
                .lineLimit(1)
                .frame(width: 100, alignment: .leading)
        }
    }
}
