import AppKit
import SwiftUI
import Combine

/// Owns the NSStatusItem and manages popover show/hide.
class StatusBarController {
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    private let monitor: SystemMonitorService
    private let settings: AppSettings
    private var cancellables = Set<AnyCancellable>()

    init() {
        monitor = SystemMonitorService()
        settings = AppSettings()

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        popover = NSPopover()
        popover.contentSize = NSSize(width: 280, height: 320)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: PopoverView()
                .environmentObject(monitor)
                .environmentObject(settings)
        )

        if let button = statusItem.button {
            button.title = "⬆ SysBar"
            button.action = #selector(togglePopover)
            button.target = self
        }

        // Restart monitor when refresh interval changes
        settings.$refreshInterval
            .removeDuplicates()
            .sink { [weak self] interval in
                self?.monitor.startMonitoring(interval: interval)
            }
            .store(in: &cancellables)

        // Keep status bar text in sync with metrics and settings
        monitor.$metrics
            .combineLatest(settings.$showTextInMenuBar)
            .receive(on: RunLoop.main)
            .sink { [weak self] metrics, showText in
                self?.updateStatusBarTitle(metrics, showText: showText)
            }
            .store(in: &cancellables)
    }

    @objc private func togglePopover() {
        if popover.isShown {
            popover.performClose(nil)
        } else if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    private func updateStatusBarTitle(_ metrics: SystemMetrics, showText: Bool) {
        if showText {
            let cpu = String(format: "CPU %.0f%%", metrics.cpuUsage * 100)
            let ram = String(format: "RAM %.0f%%", metrics.ramFraction * 100)
            statusItem.button?.title = "\(cpu)  \(ram)"
        } else {
            statusItem.button?.title = "⬆"
        }
    }
}
