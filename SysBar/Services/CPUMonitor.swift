import Foundation
import Darwin

/// Reads CPU usage via host_processor_info, diffing tick counts between calls.
class CPUMonitor {
    private var previousInfo: [Int32] = []

    /// Returns total CPU usage as a fraction 0.0–1.0.
    func usage() -> Double {
        var numCPUsU: natural_t = 0
        var cpuInfo: processor_info_array_t?
        var numCpuInfo: mach_msg_type_number_t = 0

        let result = host_processor_info(
            mach_host_self(),
            PROCESSOR_CPU_LOAD_INFO,
            &numCPUsU,
            &cpuInfo,
            &numCpuInfo
        )
        guard result == KERN_SUCCESS, let info = cpuInfo else { return 0 }

        defer {
            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: info), vm_size_t(numCpuInfo))
        }

        let count = Int(numCpuInfo)
        var current = [Int32](repeating: 0, count: count)
        for i in 0..<count { current[i] = info[i] }

        guard previousInfo.count == count else {
            previousInfo = current
            return 0
        }

        var totalUsed: Int32 = 0
        var totalAll: Int32 = 0
        let stride = Int(CPU_STATE_MAX)

        for core in 0..<Int(numCPUsU) {
            let base = core * stride
            let user   = current[base + Int(CPU_STATE_USER)]   - previousInfo[base + Int(CPU_STATE_USER)]
            let system = current[base + Int(CPU_STATE_SYSTEM)] - previousInfo[base + Int(CPU_STATE_SYSTEM)]
            let idle   = current[base + Int(CPU_STATE_IDLE)]   - previousInfo[base + Int(CPU_STATE_IDLE)]
            let nice   = current[base + Int(CPU_STATE_NICE)]   - previousInfo[base + Int(CPU_STATE_NICE)]
            totalUsed += user + system + nice
            totalAll  += user + system + nice + idle
        }

        previousInfo = current
        return totalAll > 0 ? Double(totalUsed) / Double(totalAll) : 0
    }
}
