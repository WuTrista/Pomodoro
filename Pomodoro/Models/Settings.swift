import Foundation

struct Settings: Codable {
    var workDuration: Int      // minutes
    var shortBreakDuration: Int
    var longBreakDuration: Int
    var longBreakInterval: Int // number of pomodoros before long break

    static let `default` = Settings(
        workDuration: 25,
        shortBreakDuration: 5,
        longBreakDuration: 15,
        longBreakInterval: 4
    )

    var workSeconds: Int { workDuration * 60 }
    var shortBreakSeconds: Int { shortBreakDuration * 60 }
    var longBreakSeconds: Int { longBreakDuration * 60 }
}

final class SettingsStore: ObservableObject {
    @Published var settings: Settings {
        didSet { save() }
    }

    private let key = "pomodoro_settings"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(Settings.self, from: data) {
            settings = decoded
        } else {
            settings = .default
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
