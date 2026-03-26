import Foundation
import Darwin

/// Reads physical RAM and swap statistics via host_statistics64 and sysctl.
class MemoryMonitor {
    private let pageSize: UInt64 = {
        UInt64(vm_kernel_page_size)
    }()

    func fill(into metrics: inout SystemMetrics) {
        fillRAM(into: &metrics)
        fillSwap(into: &metrics)
    }

    // MARK: - RAM

    private func fillRAM(into metrics: inout SystemMetrics) {
        var vmStats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)

        let result = withUnsafeMutablePointer(to: &vmStats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        guard result == KERN_SUCCESS else { return }

        var totalRam: UInt64 = 0
        var size = MemoryLayout<UInt64>.stride
        sysctlbyname("hw.memsize", &totalRam, &size, nil, 0)

        let used = (UInt64(vmStats.active_count) +
                    UInt64(vmStats.wire_count) +
                    UInt64(vmStats.compressor_page_count)) * pageSize

        metrics.ramTotal = totalRam
        metrics.ramUsed = min(used, totalRam)
    }

    // MARK: - Swap

    private func fillSwap(into metrics: inout SystemMetrics) {
        var swapInfo = xsw_usage()
        var size = MemoryLayout<xsw_usage>.stride
        sysctlbyname("vm.swapusage", &swapInfo, &size, nil, 0)
        metrics.swapTotal = swapInfo.xsu_total
        metrics.swapUsed = swapInfo.xsu_used
    }
}
