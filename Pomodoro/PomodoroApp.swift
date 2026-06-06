import SwiftUI

@main
struct PomodoroApp: App {
    init() {
        NotificationService.shared.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 440, minHeight: 520)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 440, height: 560)
    }
}
