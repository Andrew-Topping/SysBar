import Foundation

/// Reads boot volume disk usage via statvfs.
class DiskMonitor {
    func fill(into metrics: inout SystemMetrics) {
        var stat = statvfs()
        guard statvfs("/", &stat) == 0 else { return }

        // f_frsize is the fundamental block size; f_bsize can be the preferred I/O size
        let blockSize = UInt64(stat.f_frsize)
        let total = UInt64(stat.f_blocks) * blockSize
        let free  = UInt64(stat.f_bavail) * blockSize  // f_bavail = space available to non-root

        metrics.diskTotal = total
        metrics.diskUsed = total > free ? total - free : 0
    }
}
