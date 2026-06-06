import Foundation

enum TimerPhase: String, Codable {
    case work
    case shortBreak
    case longBreak
}

enum TimerState {
    case idle
    case running
    case paused
}
