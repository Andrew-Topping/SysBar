import Foundation

struct ProcessEntry: Identifiable {
    let id: Int32       // pid
    let name: String
    let cpuPercent: Double
    let ramBytes: UInt64
}
