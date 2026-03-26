import AppKit
import SwiftUI

/// Owns the NSStatusItem and manages popover show/hide.
class StatusBarController {
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    private let monitor: SystemMonitorService

    init() {
        monitor = SystemMonitorService()

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        popover = NSPopover()
        popover.contentSize = NSSize(width: 280, height: 320)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: PopoverView().environmentObject(monitor)
        )

        if let button = statusItem.button {
            button.title = "⬆ SysBar"
            button.action = #selector(togglePopover)
            button.target = self
        }

        // Keep status bar text in sync with metrics
        monitor.$metrics
            .receive(on: RunLoop.main)
            .sink { [weak self] metrics in
                self?.updateStatusBarTitle(metrics)
            }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

    @objc private func togglePopover() {
        if popover.isShown {
            popover.performClose(nil)
        } else if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    private func updateStatusBarTitle(_ metrics: SystemMetrics) {
        let cpu = String(format: "CPU %.0f%%", metrics.cpuUsage * 100)
        let ram = String(format: "RAM %.0f%%", metrics.ramFraction * 100)
        statusItem.button?.title = "\(cpu)  \(ram)"
    }
}
