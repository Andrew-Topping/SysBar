import Foundation

/// Static formatting helpers used across views.
enum Formatters {
    static func percent(_ fraction: Double) -> String {
        String(format: "%.0f%%", fraction * 100)
    }

    static func bytes(_ bytes: UInt64) -> String {
        let gb = Double(bytes) / 1_073_741_824
        let mb = Double(bytes) / 1_048_576
        if gb >= 1 { return String(format: "%.1f GB", gb) }
        return String(format: "%.0f MB", mb)
    }

    static func memoryUsed(_ used: UInt64, of total: UInt64) -> String {
        let usedGB  = Double(used)  / 1_073_741_824
        let totalGB = Double(total) / 1_073_741_824
        if totalGB >= 1 {
            return String(format: "%.1f / %.0f GB", usedGB, totalGB)
        }
        let usedMB  = Double(used)  / 1_048_576
        let totalMB = Double(total) / 1_048_576
        return String(format: "%.0f / %.0f MB", usedMB, totalMB)
    }

    static func bytesPerSecond(_ bps: Double) -> String {
        switch bps {
        case ..<1_024:              return "0 KB/s"
        case ..<1_048_576:         return String(format: "%.0f KB/s", bps / 1_024)
        case ..<1_073_741_824:     return String(format: "%.1f MB/s", bps / 1_048_576)
        default:                   return String(format: "%.2f GB/s", bps / 1_073_741_824)
        }
    }

    static func uptime(_ interval: TimeInterval) -> String {
        let total = Int(interval)
        let days  = total / 86400
        let hours = (total % 86400) / 3600
        let mins  = (total % 3600) / 60
        if days > 0 { return "\(days)d \(hours)h \(mins)m" }
        if hours > 0 { return "\(hours)h \(mins)m" }
        return "\(mins)m"
    }
}
