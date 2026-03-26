import Foundation
import Darwin

/// Reads all running processes via sysctl and returns the top N by CPU usage.
class ProcessMonitor {
    // FSCALE = 2048 on macOS — kernel fixed-point denominator for p_pctcpu
    private let fscale: Double = 2048.0

    func topByCPU(limit: Int = 5) -> [ProcessEntry] {
        allProcesses()
            .sorted { $0.cpuPercent > $1.cpuPercent }
            .prefix(limit)
            .map { $0 }
    }

    // MARK: - sysctl enumeration

    private func allProcesses() -> [ProcessEntry] {
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0]
        var size = 0
        guard sysctl(&mib, 4, nil, &size, nil, 0) == 0, size > 0 else { return [] }

        let count = size / MemoryLayout<kinfo_proc>.stride
        var procs = [kinfo_proc](repeating: kinfo_proc(), count: count)
        guard sysctl(&mib, 4, &procs, &size, nil, 0) == 0 else { return [] }

        return procs.compactMap { proc -> ProcessEntry? in
            let pid = proc.kp_proc.p_pid
            guard pid > 1 else { return nil }

            let name = processName(from: proc)
            let cpu  = Double(proc.kp_proc.p_pctcpu) / fscale * 100.0
            let ram  = residentMemory(for: pid)

            return ProcessEntry(id: pid, name: name, cpuPercent: cpu, ramBytes: ram)
        }
    }

    // MARK: - Helpers

    private func processName(from proc: kinfo_proc) -> String {
        withUnsafeBytes(of: proc.kp_proc.p_comm) { raw in
            let bytes = raw.bindMemory(to: UInt8.self)
            let name  = bytes.prefix(while: { $0 != 0 })
            return String(bytes: name, encoding: .utf8) ?? "?"
        }
    }

    private func residentMemory(for pid: Int32) -> UInt64 {
        var taskInfo = proc_taskinfo()
        let size = proc_pidinfo(pid, PROC_PIDTASKINFO, 0, &taskInfo,
                                Int32(MemoryLayout<proc_taskinfo>.size))
        return size > 0 ? taskInfo.pti_resident_size : 0
    }
}
