import SwiftUI

@main
struct PomodoroApp: App {
    init() {
        NotificationService.shared.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 400, minHeight: 520)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 420, height: 540)
    }
}
