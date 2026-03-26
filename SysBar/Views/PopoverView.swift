import SwiftUI

struct PopoverView: View {
    @EnvironmentObject var monitor: SystemMonitorService

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerBar
            Divider().background(Color.gray.opacity(0.4))
            metricsPanel
        }
        .frame(width: 280)
        .background(Color(hex: "#1a1a1a"))
    }

    // MARK: - Header

    private var headerBar: some View {
        ZStack {
            Text("SysBar")
                .font(.system(.headline, design: .monospaced))
                .foregroundColor(.white)
            HStack {
                Spacer()
                Text("↻ 2s")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(hex: "#222222"))
    }

    // MARK: - Metrics panel

    private var metricsPanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Primary metrics
            MetricRowView(
                label: "CPU",
                fraction: monitor.metrics.cpuUsage,
                valueText: Formatters.percent(monitor.metrics.cpuUsage)
            )
            MetricRowView(
                label: "RAM",
                fraction: monitor.metrics.ramFraction,
                valueText: Formatters.memoryUsed(monitor.metrics.ramUsed, of: monitor.metrics.ramTotal)
            )
            MetricRowView(
                label: "SWAP",
                fraction: monitor.metrics.swapFraction,
                valueText: Formatters.bytes(monitor.metrics.swapUsed)
            )
            MetricRowView(
                label: "DISK",
                fraction: monitor.metrics.diskFraction,
                valueText: Formatters.memoryUsed(monitor.metrics.diskUsed, of: monitor.metrics.diskTotal)
            )

            Divider().background(Color.gray.opacity(0.3)).padding(.vertical, 4)

            // Secondary metrics
            secondaryRow(label: "Uptime", value: Formatters.uptime(monitor.metrics.uptime))
            secondaryRow(
                label: "Load",
                value: String(format: "%.2f  %.2f  %.2f",
                              monitor.metrics.loadAvg1m,
                              monitor.metrics.loadAvg5m,
                              monitor.metrics.loadAvg15m)
            )
        }
        .padding(12)
        .background(Color(hex: "#1a1a1a"))
    }

    private func secondaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.gray)
                .frame(width: 48, alignment: .leading)
            Text(value)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(Color(hex: "#cccccc"))
        }
    }
}
