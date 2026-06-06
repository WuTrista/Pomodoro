import SwiftUI

// MARK: - Color Palette

extension Color {
    static let sagePrimary   = Color(red: 0.561, green: 0.592, blue: 0.475)
    static let sageDark      = Color(red: 0.357, green: 0.392, blue: 0.290)
    static let sageLight     = Color(red: 0.773, green: 0.812, blue: 0.690)
    static let warmStone     = Color(red: 0.961, green: 0.941, blue: 0.910)
    static let warmCard      = Color(red: 0.929, green: 0.910, blue: 0.867)
    static let earthText     = Color(red: 0.239, green: 0.208, blue: 0.161)
    static let terracotta    = Color(red: 0.757, green: 0.482, blue: 0.376)
    static let creamWhite    = Color(red: 1.000, green: 0.988, blue: 0.969)
}

// MARK: - Main Content View

struct ContentView: View {
    @StateObject private var viewModel = TimerViewModel()
    @State private var showSettings = false
    @State private var showStats = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.creamWhite, .warmStone, .warmCard.opacity(0.6)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar
                Spacer()
                timerRing
                Spacer()
                controlSection
                miniStats
            }
            .padding(.horizontal, 32)
        }
        .frame(minWidth: 400, minHeight: 520)
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showStats) {
            StatisticsView(viewModel: viewModel)
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            phasePill
            Spacer()
            HStack(spacing: 10) {
                Button(action: { showStats = true }) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.earthText.opacity(0.6))
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.plain)

                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.earthText.opacity(0.6))
                        .frame(width: 30, height: 30)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 20)
    }

    private var phasePill: some View {
        HStack(spacing: 7) {
            Circle()
                .fill(phaseColor)
                .frame(width: 7, height: 7)
            Text(viewModel.phaseLabel)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.earthText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(
            Capsule()
                .fill(Color.sageLight.opacity(0.25))
        )
        .overlay(
            Capsule()
                .stroke(Color.sageLight.opacity(0.4), lineWidth: 0.5)
        )
    }

    // MARK: - Timer Ring

    private var timerRing: some View {
        ZStack {
            // Outer subtle shadow ring
            Circle()
                .stroke(.black.opacity(0.04), lineWidth: 18)
                .frame(width: 232, height: 232)
                .blur(radius: 4)
                .offset(y: 2)

            // Background track
            Circle()
                .stroke(
                    Color.sageLight.opacity(0.2),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .frame(width: 220, height: 220)

            // Progress track
            Circle()
                .trim(from: 0, to: viewModel.progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            .sagePrimary,
                            .sageDark,
                            .sagePrimary
                        ]),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .frame(width: 220, height: 220)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: viewModel.progress)

            // Glowing dot at progress head
            if viewModel.progress > 0 && viewModel.progress < 1 {
                Circle()
                    .fill(Color.sagePrimary)
                    .frame(width: 10, height: 10)
                    .shadow(color: .sagePrimary.opacity(0.5), radius: 6)
                    .offset(y: -110)
                    .rotationEffect(.degrees(360 * viewModel.progress))
                    .animation(.linear(duration: 1), value: viewModel.progress)
            }

            // Center content
            VStack(spacing: 2) {
                Text(timeString(viewModel.remainingSeconds))
                    .font(.system(size: 58, weight: .thin, design: .monospaced))
                    .monospacedDigit()
                    .foregroundColor(.earthText)

                Text("已完成 \(viewModel.completedPomodoros) 个番茄")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.earthText.opacity(0.45))
            }
        }
        .scaleEffect(viewModel.timerState == .running ? 1.0 : 0.96)
        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: viewModel.timerState == .running)
    }

    // MARK: - Controls

    private var controlSection: some View {
        VStack(spacing: 16) {
            // Primary play/pause button
            Button(action: { viewModel.start() }) {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.timerState == .running ? "pause.fill" : "play.fill")
                        .font(.system(size: 16, weight: .semibold))
                    Text(viewModel.timerState == .running ? "暂停" : viewModel.timerState == .paused ? "继续" : "开始")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.creamWhite)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(phaseColor)
                        .shadow(color: phaseColor.opacity(0.35), radius: 8, y: 3)
                )
            }
            .buttonStyle(.plain)

            // Secondary buttons
            HStack(spacing: 20) {
                secondaryButton(
                    icon: "arrow.counterclockwise",
                    label: "重置",
                    action: { viewModel.reset() },
                    disabled: viewModel.timerState == .idle && viewModel.phase == .work && viewModel.completedPomodoros == 0
                )

                secondaryButton(
                    icon: "forward.end.fill",
                    label: "跳过",
                    action: { viewModel.skip() },
                    disabled: viewModel.timerState == .idle
                )
            }
        }
        .padding(.top, 8)
    }

    private func secondaryButton(icon: String, label: String, action: @escaping () -> Void, disabled: Bool) -> some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .medium))
                Text(label)
                    .font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(disabled ? .earthText.opacity(0.25) : .earthText.opacity(0.55))
            .padding(.horizontal, 18)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(disabled ? Color.earthText.opacity(0.1) : Color.sageLight.opacity(0.4), lineWidth: 0.8)
            )
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }

    // MARK: - Mini Stats

    private var miniStats: some View {
        HStack(spacing: 0) {
            // Today count
            VStack(alignment: .leading, spacing: 2) {
                Text("今日")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.earthText.opacity(0.4))
                Text("\(viewModel.todayCount)")
                    .font(.system(size: 28, weight: .light, design: .monospaced))
                    .monospacedDigit()
                    .foregroundColor(.sageDark)
            }

            Spacer()

            // Weekly mini bars
            HStack(alignment: .bottom, spacing: 6) {
                ForEach(viewModel.weeklyCounts, id: \.0) { day, count in
                    VStack(spacing: 3) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(count > 0 ? Color.sagePrimary.opacity(0.6) : Color.sageLight.opacity(0.2))
                            .frame(width: 14, height: max(CGFloat(count) * 18, 3))
                        Text(day)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.earthText.opacity(0.3))
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.warmCard.opacity(0.5))
        )
        .padding(.bottom, 24)
        .padding(.top, 12)
    }

    // MARK: - Helpers

    private var phaseColor: Color {
        switch viewModel.phase {
        case .work:       return .sagePrimary
        case .shortBreak: return .sageLight
        case .longBreak:  return .sageDark
        }
    }

    private func timeString(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
