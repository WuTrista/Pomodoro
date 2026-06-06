import Foundation

struct PomodoroRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    let durationSeconds: Int
    let phase: TimerPhase

    init(id: UUID = UUID(), date: Date = Date(), durationSeconds: Int, phase: TimerPhase) {
        self.id = id
        self.date = date
        self.durationSeconds = durationSeconds
        self.phase = phase
    }
}
