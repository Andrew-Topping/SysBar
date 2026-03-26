import Foundation
import Combine

/// Orchestrates all metric monitors and publishes a unified SystemMetrics snapshot.
class SystemMonitorService: ObservableObject {
    @Published var metrics = SystemMetrics()

    /// Set by StatusBarController so we skip expensive work when popover is hidden.
    var isPopoverVisible = false

    private let cpu      = CPUMonitor()
    private let memory   = MemoryMonitor()
    private let disk     = DiskMonitor()
    private let network  = NetworkMonitor()
    private let processes = ProcessMonitor()

    /// All metric reads run on this queue — keeps the main thread free.
    private let queue = DispatchQueue(label: "com.sysbar.monitor", qos: .utility)
    private var timer: AnyCancellable?

    /// Process list is expensive — only refresh every N ticks.
    private var tickCount = 0
    private let processTickInterval = 3   // refresh processes every 3rd tick
    private var cachedProcesses: [ProcessEntry] = []

    init() {
        startMonitoring()
    }

    func startMonitoring(interval: TimeInterval = 2.0) {
        timer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.queue.async { self?.refresh() }
            }
        queue.async { self.refresh() }
    }

    func stopMonitoring() {
        timer = nil
    }

    // MARK: - Refresh (runs on background queue)

    private func refresh() {
        var snapshot = SystemMetrics()
        snapshot.cpuUsage = cpu.usage()
        memory.fill(into: &snapshot)
        disk.fill(into: &snapshot)
        network.fill(into: &snapshot)
        snapshot.uptime       = Self.systemUptime()
        snapshot.thermalState = ProcessInfo.processInfo.thermalState

        // Only update process list when popover is open, and only every N ticks
        if isPopoverVisible {
            tickCount += 1
            if tickCount % processTickInterval == 0 || cachedProcesses.isEmpty {
                cachedProcesses = processes.topByCPU()
            }
        }
        snapshot.topProcesses = cachedProcesses

        DispatchQueue.main.async { [weak self] in
            self?.metrics = snapshot
        }
    }

    // MARK: - Uptime

    private static func systemUptime() -> TimeInterval {
        var boottime = timeval()
        var size = MemoryLayout<timeval>.stride
        sysctlbyname("kern.boottime", &boottime, &size, nil, 0)
        let boot = Date(timeIntervalSince1970: TimeInterval(boottime.tv_sec))
        return Date().timeIntervalSince(boot)
    }
}
