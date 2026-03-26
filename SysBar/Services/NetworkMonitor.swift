import Foundation
import Darwin

/// Reads network interface byte counters and diffs them each tick to produce bytes/sec.
class NetworkMonitor {
    private var previousBytesIn:  UInt64 = 0
    private var previousBytesOut: UInt64 = 0
    private var previousTime: Date = Date()

    func fill(into metrics: inout SystemMetrics) {
        let (bytesIn, bytesOut) = totalBytes()
        let now = Date()
        let elapsed = now.timeIntervalSince(previousTime)

        if elapsed > 0 && (previousBytesIn > 0 || previousBytesOut > 0) {
            let inDelta  = bytesIn  >= previousBytesIn  ? bytesIn  - previousBytesIn  : 0
            let outDelta = bytesOut >= previousBytesOut ? bytesOut - previousBytesOut : 0
            metrics.networkDownload = Double(inDelta)  / elapsed
            metrics.networkUpload   = Double(outDelta) / elapsed
        }

        previousBytesIn  = bytesIn
        previousBytesOut = bytesOut
        previousTime     = now
    }

    // MARK: - Interface enumeration

    private func totalBytes() -> (UInt64, UInt64) {
        var totalIn:  UInt64 = 0
        var totalOut: UInt64 = 0

        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return (0, 0) }
        defer { freeifaddrs(ifaddr) }

        var ptr = ifaddr
        while let interface = ptr {
            defer { ptr = interface.pointee.ifa_next }

            let flags = Int32(interface.pointee.ifa_flags)
            let isUp       = flags & IFF_UP      != 0
            let isRunning  = flags & IFF_RUNNING != 0
            let isLoopback = flags & IFF_LOOPBACK != 0

            guard isUp, isRunning, !isLoopback else { continue }
            guard let addr = interface.pointee.ifa_addr,
                  addr.pointee.sa_family == UInt8(AF_LINK) else { continue }

            if let data = interface.pointee.ifa_data {
                let ifData = data.assumingMemoryBound(to: if_data.self)
                totalIn  += UInt64(ifData.pointee.ifi_ibytes)
                totalOut += UInt64(ifData.pointee.ifi_obytes)
            }
        }

        return (totalIn, totalOut)
    }
}
