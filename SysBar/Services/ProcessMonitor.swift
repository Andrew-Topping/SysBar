import Foundation
import Darwin

/// Reads running processes via sysctl and returns the top N by CPU usage.
/// Two-phase approach: cheap sysctl first, expensive proc_pidinfo only for top candidates.
class ProcessMonitor {
    private let fscale: Double = 2048.0

    func topByCPU(limit: Int = 5) -> [ProcessEntry] {
        // Phase 1: get all process basic info cheaply (no proc_pidinfo)
        let candidates = allBasicInfo()
            .sorted { $0.cpuPercent > $1.cpuPercent }
            .prefix(limit * 2)   // grab 2x candidates to filter from

        // Phase 2: only call proc_pidinfo for the top candidates
        return candidates
            .map { entry in
                ProcessEntry(
                    id:         entry.id,
                    name:       entry.name,
                    cpuPercent: entry.cpuPercent,
                    ramBytes:   residentMemory(for: entry.id)
                )
            }
            .sorted { $0.cpuPercent > $1.cpuPercent }
            .prefix(limit)
            .map { $0 }
    }

    // MARK: - Phase 1: cheap sysctl pass

    private func allBasicInfo() -> [ProcessEntry] {
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
            // ramBytes = 0 at this stage — filled in phase 2 for top candidates only
            return ProcessEntry(id: pid, name: name, cpuPercent: cpu, ramBytes: 0)
        }
    }

    // MARK: - Phase 2: expensive proc_pidinfo (called only for top N)

    private func residentMemory(for pid: Int32) -> UInt64 {
        var taskInfo = proc_taskinfo()
        let size = proc_pidinfo(pid, PROC_PIDTASKINFO, 0, &taskInfo,
                                Int32(MemoryLayout<proc_taskinfo>.size))
        return size > 0 ? taskInfo.pti_resident_size : 0
    }

    // MARK: - Helpers

    private func processName(from proc: kinfo_proc) -> String {
        withUnsafeBytes(of: proc.kp_proc.p_comm) { raw in
            let bytes = raw.bindMemory(to: UInt8.self)
            return String(bytes: bytes.prefix(while: { $0 != 0 }), encoding: .utf8) ?? "?"
        }
    }
}
