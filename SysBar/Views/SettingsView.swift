import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings
    let onBack: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerBar
            Divider().background(Color.gray.opacity(0.4))
            form
        }
        .background(settings.theme.background)
    }

    // MARK: - Header

    private var headerBar: some View {
        ZStack {
            Text("Settings")
                .font(.system(.headline, design: .monospaced))
                .foregroundColor(settings.theme.titleColor)
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(settings.theme.labelColor)
                }
                .buttonStyle(.plain)
                Spacer()
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(settings.theme.headerBackground)
    }

    // MARK: - Form

    private var form: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Refresh rate
            VStack(alignment: .leading, spacing: 6) {
                Text("REFRESH RATE")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(settings.theme.labelColor)
                HStack(spacing: 6) {
                    ForEach(AppSettings.refreshOptions, id: \.self) { interval in
                        intervalButton(interval)
                    }
                }
            }

            Divider().background(Color.gray.opacity(0.2))

            // Theme
            VStack(alignment: .leading, spacing: 6) {
                Text("THEME")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(settings.theme.labelColor)
                HStack(spacing: 6) {
                    ForEach(Theme.allCases) { theme in
                        themeButton(theme)
                    }
                }
            }

            Divider().background(Color.gray.opacity(0.2))

            // Menu bar text
            HStack {
                Text("Show text in menu bar")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(settings.theme.valueColor)
                Spacer()
                Toggle("", isOn: $settings.showTextInMenuBar)
                    .toggleStyle(.switch)
                    .scaleEffect(0.75)
                    .frame(width: 40)
            }

            Divider().background(Color.gray.opacity(0.2))

            // Quit
            Button(action: { NSApplication.shared.terminate(nil) }) {
                HStack {
                    Image(systemName: "power")
                        .font(.system(size: 11))
                    Text("Quit SysBar")
                        .font(.system(size: 11, design: .monospaced))
                }
                .foregroundColor(Color(hex: "#ff4444"))
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
    }

    // MARK: - Buttons

    private func intervalButton(_ interval: Double) -> some View {
        let label = interval < 60 ? "\(Int(interval))s" : "\(Int(interval / 60))m"
        let selected = settings.refreshInterval == interval
        return Button(action: { settings.refreshInterval = interval }) {
            Text(label)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(selected ? settings.theme.background : settings.theme.valueColor)
                .frame(width: 36, height: 24)
                .background(selected ? settings.theme.barColor(for: 0.3) : Color.white.opacity(0.06))
                .cornerRadius(4)
        }
        .buttonStyle(.plain)
    }

    private func themeButton(_ theme: Theme) -> some View {
        let selected = settings.theme == theme
        return Button(action: { settings.theme = theme }) {
            Text(theme.displayName)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(selected ? settings.theme.background : settings.theme.valueColor)
                .padding(.horizontal, 8)
                .frame(height: 24)
                .background(selected ? settings.theme.barColor(for: 0.3) : Color.white.opacity(0.06))
                .cornerRadius(4)
        }
        .buttonStyle(.plain)
    }
}
