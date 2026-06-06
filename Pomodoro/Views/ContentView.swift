import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TimerViewModel()

    var body: some View {
        TabView {
            TimerView(viewModel: viewModel)
                .tabItem { Label("计时器", systemImage: "timer") }

            StatisticsView(viewModel: viewModel)
                .tabItem { Label("统计", systemImage: "chart.bar.fill") }

            SettingsView()
                .tabItem { Label("设置", systemImage: "gearshape.fill") }
        }
    }
}

struct TimerView: View {
    @ObservedObject var viewModel: TimerViewModel

    var body: some View {
        VStack(spacing: 30) {
            Text(viewModel.phaseLabel)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(phaseColor)

            ZStack {
                Circle()
                    .stroke(lineWidth: 12)
                    .foregroundColor(Color.gray.opacity(0.15))

                Circle()
                    .trim(from: 0, to: viewModel.progress)
                    .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .foregroundColor(phaseColor)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: viewModel.progress)

                VStack(spacing: 4) {
                    Text(timeString(viewModel.remainingSeconds))
                        .font(.system(size: 56, weight: .thin, design: .monospaced))
                        .monospacedDigit()

                    Text("已完成 \(viewModel.completedPomodoros) 个番茄")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 260, height: 260)
            .padding(.top, 20)

            HStack(spacing: 24) {
                Button(action: { viewModel.start() }) {
                    Label(
                        viewModel.timerState == .running ? "暂停" : "开始",
                        systemImage: viewModel.timerState == .running ? "pause.fill" : "play.fill"
                    )
                    .font(.title3)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .tint(phaseColor)

                Button(action: { viewModel.reset() }) {
                    Label("重置", systemImage: "arrow.counterclockwise")
                        .font(.title3)
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.timerState == .idle && viewModel.phase == .work && viewModel.completedPomodoros == 0)

                Button(action: { viewModel.skip() }) {
                    Label("跳过", systemImage: "forward.end.fill")
                        .font(.title3)
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.timerState == .idle)
            }

            Spacer()
        }
        .padding()
        .frame(minWidth: 400, minHeight: 450)
    }

    private var phaseColor: Color {
        switch viewModel.phase {
        case .work: return .red
        case .shortBreak: return .green
        case .longBreak: return .blue
        }
    }

    private func timeString(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
