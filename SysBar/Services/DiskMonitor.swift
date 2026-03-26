import Foundation

/// Reads boot volume disk usage via statvfs.
class DiskMonitor {
    func fill(into metrics: inout SystemMetrics) {
        var stat = statvfs()
        guard statvfs("/", &stat) == 0 else { return }

        let blockSize = UInt64(stat.f_bsize)
        let total = UInt64(stat.f_blocks) * blockSize
        let free  = UInt64(stat.f_bfree)  * blockSize

        metrics.diskTotal = total
        metrics.diskUsed = total > free ? total - free : 0
    }
}
