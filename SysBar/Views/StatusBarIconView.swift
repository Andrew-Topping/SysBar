import SwiftUI

/// Rendered offscreen via ImageRenderer and set as the NSStatusItem button image.
/// HStack naturally baseline-aligns Image and Text — no manual offset needed.
struct StatusBarIconView: View {
    let cpuStr: String
    let ramStr: String

    var body: some View {
        HStack(spacing: 8) {
            metric(icon: "cpu", value: cpuStr)
            metric(icon: "memorychip", value: ramStr)
        }
        .font(.system(size: 11.5, weight: .medium))
        .foregroundColor(.black)
        .fixedSize()
    }

    private func metric(icon: String, value: String) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .imageScale(.small)
            Text(value)
                .monospacedDigit()
                .frame(minWidth: 28, alignment: .leading) // fixed width keeps RAM icon static
        }
    }
}
