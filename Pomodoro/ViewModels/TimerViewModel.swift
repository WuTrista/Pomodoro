import Foundation
import Combine

final class TimerViewModel: ObservableObject {
    @Published var timerState: TimerState = .idle
    @Published var phase: TimerPhase = .work
    @Published var remainingSeconds: Int = 0
    @Published var totalSeconds: Int = 0
    @Published var completedPomodoros: Int = 0

    private let settingsStore: SettingsStore
    private var cancellable: AnyCancellable?
    private var records: [PomodoroRecord] = []

    init(settingsStore: SettingsStore = SettingsStore()) {
        self.settingsStore = settingsStore
        remainingSeconds = settingsStore.settings.workSeconds
        totalSeconds = settingsStore.settings.workSeconds
        loadRecords()
    }

    var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return Double(totalSeconds - remainingSeconds) / Double(totalSeconds)
    }

    var phaseLabel: String {
        switch phase {
        case .work: return "工作中"
        case .shortBreak: return "短休息"
        case .longBreak: return "长休息"
        }
    }

    // MARK: - Actions

    func start() {
        switch timerState {
        case .idle:
            remainingSeconds = phaseSeconds
            totalSeconds = phaseSeconds
            fallthrough
        case .paused:
            timerState = .running
            startTimer()
        case .running:
            timerState = .paused
            stopTimer()
        }
    }

    func reset() {
        stopTimer()
        timerState = .idle
        phase = .work
        completedPomodoros = 0
        remainingSeconds = settingsStore.settings.workSeconds
        totalSeconds = settingsStore.settings.workSeconds
    }

    func skip() {
        stopTimer()
        switchToNextPhase()
    }

    // MARK: - Timer

    private func startTimer() {
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func stopTimer() {
        cancellable?.cancel()
        cancellable = nil
    }

    private func tick() {
        guard remainingSeconds > 0 else {
            finishCurrentPhase()
            return
        }
        remainingSeconds -= 1
    }

    private func finishCurrentPhase() {
        stopTimer()

        if phase == .work {
            completedPomodoros += 1
            saveRecord(durationSeconds: totalSeconds)
        }

        NotificationService.shared.sendTimerFinished(phase: phase)
        switchToNextPhase()
    }

    private func switchToNextPhase() {
        let settings = settingsStore.settings

        switch phase {
        case .work:
            if completedPomodoros % settings.longBreakInterval == 0 {
                phase = .longBreak
                remainingSeconds = settings.longBreakSeconds
                totalSeconds = settings.longBreakSeconds
            } else {
                phase = .shortBreak
                remainingSeconds = settings.shortBreakSeconds
                totalSeconds = settings.shortBreakSeconds
            }
        case .shortBreak, .longBreak:
            phase = .work
            remainingSeconds = settings.workSeconds
            totalSeconds = settings.workSeconds
        }

        timerState = .idle
    }

    private var phaseSeconds: Int {
        let settings = settingsStore.settings
        switch phase {
        case .work: return settings.workSeconds
        case .shortBreak: return settings.shortBreakSeconds
        case .longBreak: return settings.longBreakSeconds
        }
    }

    // MARK: - Records

    private func saveRecord(durationSeconds: Int) {
        let record = PomodoroRecord(durationSeconds: durationSeconds, phase: .work)
        records.append(record)
        persistRecords()
    }

    private func persistRecords() {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: "pomodoro_records")
        }
    }

    private func loadRecords() {
        if let data = UserDefaults.standard.data(forKey: "pomodoro_records"),
           let decoded = try? JSONDecoder().decode([PomodoroRecord].self, from: data) {
            records = decoded
        }
    }

    // MARK: - Statistics

    var todayCount: Int {
        let calendar = Calendar.current
        return records.filter { calendar.isDateInToday($0.date) }.count
    }

    var weeklyCounts: [(String, Int)] {
        let calendar = Calendar.current
        let today = Date()
        let weekdays = ["日", "一", "二", "三", "四", "五", "六"]

        return (0..<7).map { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else {
                return ("", 0)
            }
            let count = records.filter { calendar.isDate($0.date, inSameDayAs: date) }.count
            let weekdayIndex = calendar.component(.weekday, from: date) - 1
            return (weekdays[weekdayIndex], count)
        }.reversed()
    }

    var totalPomodoros: Int {
        records.count
    }

    var recordsByDate: [(Date, Int)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: records) { record in
            calendar.startOfDay(for: record.date)
        }
        return grouped.map { ($0.key, $0.value.count) }
            .sorted { $0.0 > $1.0 }
    }
}
