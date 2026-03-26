import SwiftUI

struct PopoverView: View {
    @EnvironmentObject var monitor: SystemMonitorService
    @EnvironmentObject var settings: AppSettings
    @State private var showingSettings = false
    @State private var showingProcesses = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if showingSettings {
                SettingsView(onBack: { showingSettings = false })
            } else {
                headerBar
                Divider().background(Color.gray.opacity(0.4))
                metricsPanel
            }
        }
        .frame(width: 280)
        .background(settings.theme.background)
    }

    // MARK: - Header

    private var headerBar: some View {
        ZStack {
            Text("SysBar")
                .font(.system(.headline, design: .monospaced))
                .foregroundColor(settings.theme.titleColor)
            HStack {
                Spacer()
                Button(action: { showingSettings = true }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 11))
                        .foregroundColor(settings.theme.labelColor)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(settings.theme.headerBackground)
    }

    // MARK: - Metrics panel

    private var metricsPanel: some View {
        VStack(alignment: .leading, spacing: 6) {
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

            secondaryRow(label: "↓", value: Formatters.bytesPerSecond(monitor.metrics.networkDownload))
            secondaryRow(label: "↑", value: Formatters.bytesPerSecond(monitor.metrics.networkUpload))

            Divider().background(Color.gray.opacity(0.3)).padding(.vertical, 4)

            secondaryRow(label: "Uptime", value: Formatters.uptime(monitor.metrics.uptime))
            thermalRow

            Divider().background(Color.gray.opacity(0.3)).padding(.vertical, 4)
            processToggle
        }
        .padding(12)
        .background(settings.theme.background)
    }

    // MARK: - Process toggle

    private var processToggle: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("PROCESSES")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(settings.theme.labelColor)
                Spacer()
                Image(systemName: showingProcesses ? "chevron.up" : "chevron.down")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(settings.theme.labelColor)
            }
            .frame(maxWidth: .infinity, minHeight: 20)   // large tap target across full width
            .contentShape(Rectangle())                    // make entire row hittable
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) { showingProcesses.toggle() }
            }

            if showingProcesses {
                VStack(spacing: 3) {
                    ForEach(monitor.metrics.topProcesses) { proc in
                        HStack(spacing: 6) {
                            Text(proc.name)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(settings.theme.valueColor)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(String(format: "%.0f%%", proc.cpuPercent))
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(settings.theme.barColor(for: proc.cpuPercent / 100))
                                .frame(width: 36, alignment: .trailing)
                            Text(Formatters.bytes(proc.ramBytes))
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(settings.theme.labelColor)
                                .frame(width: 60, alignment: .trailing)
                        }
                    }
                }
                .padding(.top, 2)
            }
        }
    }

    private var thermalRow: some View {
        HStack {
            Text("Thermal")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(settings.theme.labelColor)
                .frame(width: 48, alignment: .leading)
            Text(monitor.metrics.thermalLabel)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(settings.theme.barColor(for: monitor.metrics.thermalFraction))
        }
    }

    private func secondaryRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(settings.theme.labelColor)
                .frame(width: 48, alignment: .leading)
            Text(value)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(settings.theme.valueColor)
        }
    }
}
