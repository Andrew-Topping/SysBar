import Foundation

/// A snapshot of all system resource metrics at a point in time.
struct SystemMetrics {
    // CPU
    var cpuUsage: Double = 0.0          // 0.0–1.0

    // Memory
    var ramUsed: UInt64 = 0             // bytes
    var ramTotal: UInt64 = 0            // bytes
    var swapUsed: UInt64 = 0            // bytes
    var swapTotal: UInt64 = 0           // bytes

    // Disk (boot volume)
    var diskUsed: UInt64 = 0            // bytes
    var diskTotal: UInt64 = 0           // bytes

    // Network (bytes/sec)
    var networkDownload: Double = 0
    var networkUpload:   Double = 0

    // Processes
    var topProcesses: [ProcessEntry] = []

    // Secondary
    var uptime: TimeInterval = 0
    var thermalState: ProcessInfo.ThermalState = .nominal

    var thermalLabel: String {
        switch thermalState {
        case .nominal:  return "None"
        case .fair:     return "Mild"
        case .serious:  return "Heavy"
        case .critical: return "Critical"
        @unknown default: return "Unknown"
        }
    }

    // Fraction used for colour-coding the thermal row (0=green, 1=red)
    var thermalFraction: Double {
        switch thermalState {
        case .nominal:  return 0.0
        case .fair:     return 0.5
        case .serious:  return 0.8
        case .critical: return 1.0
        @unknown default: return 0.0
        }
    }

    // MARK: - Computed fractions for progress bars
    var ramFraction: Double {
        ramTotal > 0 ? Double(ramUsed) / Double(ramTotal) : 0
    }
    var swapFraction: Double {
        swapTotal > 0 ? Double(swapUsed) / Double(swapTotal) : 0
    }
    var diskFraction: Double {
        diskTotal > 0 ? Double(diskUsed) / Double(diskTotal) : 0
    }
}
