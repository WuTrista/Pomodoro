import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    func sendTimerFinished(phase: TimerPhase) {
        let content = UNMutableNotificationContent()
        switch phase {
        case .work:
            content.title = "工作完成！"
            content.body = "休息一下吧"
            content.sound = .default
        case .shortBreak, .longBreak:
            content.title = "休息结束！"
            content.body = "开始下一个番茄吧"
            content.sound = .default
        }

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }
}
