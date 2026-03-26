import SwiftUI

@main
struct SysBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Menu bar app — no main window.
        // Settings window is presented from the popover gear button.
        Settings {
            EmptyView()
        }
    }
}
