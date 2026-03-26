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
    private var lastCpuStr = ""
    private var lastRamStr = ""

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
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
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
        guard let event = NSApp.currentEvent else { return }

        // Right-click → show a minimal context menu with Quit
        if event.type == .rightMouseUp {
            let menu = NSMenu()
            menu.addItem(withTitle: "Quit SysBar", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
            statusItem.menu = menu
            statusItem.button?.performClick(nil)
            statusItem.menu = nil   // remove menu so left-click still opens popover
            return
        }

        if popover.isShown {
            popover.performClose(nil)
            monitor.isPopoverVisible = false
        } else if let button = statusItem.button {
            monitor.isPopoverVisible = true
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }

    private func updateStatusBarTitle(_ metrics: SystemMetrics, showText: Bool) {
        guard let button = statusItem.button else { return }
        if showText {
            let cpuStr = String(format: "%.0f%%", metrics.cpuUsage * 100)
            let ramStr = String(format: "%.0f%%", metrics.ramFraction * 100)

            // Skip re-render if values haven't changed — ImageRenderer is not free
            guard cpuStr != lastCpuStr || ramStr != lastRamStr else { return }
            lastCpuStr = cpuStr
            lastRamStr = ramStr

            let view   = StatusBarIconView(cpuStr: cpuStr, ramStr: ramStr)
            let renderer = ImageRenderer(content: view)
            renderer.scale = NSScreen.main?.backingScaleFactor ?? 2.0
            if let img = renderer.nsImage {
                img.isTemplate    = true  // macOS recolours for light/dark menu bar automatically
                button.image      = img
                button.imagePosition  = .imageOnly
                button.imageScaling   = .scaleNone
                button.title      = ""
            }
        } else {
            button.title         = ""
            button.imagePosition = .imageOnly
            button.image         = NSImage(systemSymbolName: "cpu", accessibilityDescription: "SysBar")
        }
    }
}
