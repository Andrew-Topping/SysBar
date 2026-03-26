import Foundation
import Combine

/// Orchestrates all metric monitors and publishes a unified SystemMetrics snapshot.
class SystemMonitorService: ObservableObject {
    @Published var metrics = SystemMetrics()

    private let cpu      = CPUMonitor()
    private let memory   = MemoryMonitor()
    private let disk     = DiskMonitor()
    private let network  = NetworkMonitor()
    private let processes = ProcessMonitor()
    private var timer: AnyCancellable?

    init() {
        startMonitoring()
    }

    func startMonitoring(interval: TimeInterval = 2.0) {
        timer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.refresh()
            }
        // Fire once immediately so the UI isn't blank on launch
        refresh()
    }

    func stopMonitoring() {
        timer = nil
    }

    private func refresh() {
        var snapshot = SystemMetrics()
        snapshot.cpuUsage = cpu.usage()
        memory.fill(into: &snapshot)
        disk.fill(into: &snapshot)
        network.fill(into: &snapshot)
        snapshot.topProcesses = processes.topByCPU()
        snapshot.uptime       = Self.systemUptime()
        snapshot.thermalState = ProcessInfo.processInfo.thermalState
        metrics = snapshot
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
