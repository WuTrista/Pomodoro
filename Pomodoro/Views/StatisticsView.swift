import SwiftUI

struct StatisticsView: View {
    @ObservedObject var viewModel: TimerViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("统计")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.earthText)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.earthText.opacity(0.35))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 28)
            .padding(.top, 24)
            .padding(.bottom, 20)

            Divider()
                .overlay(Color.sageLight.opacity(0.3))

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Stat cards
                    HStack(spacing: 14) {
                        StatCard(title: "今日番茄", value: "\(viewModel.todayCount)", color: .sagePrimary)
                        StatCard(title: "总计番茄", value: "\(viewModel.totalPomodoros)", color: .sageDark)
                    }

                    // Weekly section
                    weeklySection

                    // History
                    if viewModel.totalPomodoros > 0 {
                        historySection
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 20)
                .padding(.bottom, 28)
            }
        }
        .frame(width: 420, height: 520)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.creamWhite, .warmStone]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    // MARK: - Weekly

    private var weeklySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("本周")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.earthText)

            HStack(alignment: .bottom, spacing: 14) {
                ForEach(viewModel.weeklyCounts, id: \.0) { day, count in
                    VStack(spacing: 5) {
                        Text("\(count)")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .monospacedDigit()
                            .foregroundColor(count > 0 ? .sageDark : .earthText.opacity(0.3))
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                count > 0
                                    ? LinearGradient(
                                        gradient: Gradient(colors: [.sageLight, .sagePrimary]),
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                    : LinearGradient(
                                        gradient: Gradient(colors: [.sageLight.opacity(0.15), .sageLight.opacity(0.15)]),
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                            )
                            .frame(width: 30, height: max(CGFloat(count) * 26, 4))
                            .animation(.easeOut(duration: 0.5), value: count)
                        Text(day)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.earthText.opacity(0.35))
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.warmCard.opacity(0.6))
        )
    }

    // MARK: - History

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最近记录")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.earthText)

            VStack(spacing: 0) {
                ForEach(Array(viewModel.recordsByDate.prefix(14).enumerated()), id: \.offset) { index, pair in
                    let (date, count) = pair
                    HStack {
                        Text(formatDate(date))
                            .font(.system(size: 13))
                            .foregroundColor(.earthText.opacity(0.7))
                        Spacer()
                        Text("\(count) 个番茄")
                            .font(.system(size: 13, design: .monospaced))
                            .monospacedDigit()
                            .foregroundColor(.sagePrimary)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 4)

                    if index < min(viewModel.recordsByDate.count, 14) - 1 {
                        Divider()
                            .overlay(Color.sageLight.opacity(0.2))
                    }
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.warmCard.opacity(0.6))
            )
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日"
        return formatter.string(from: date)
    }
}

// MARK: - Stat Card

private struct StatCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 38, weight: .light, design: .monospaced))
                .monospacedDigit()
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.earthText.opacity(0.45))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.warmCard.opacity(0.6))
        )
    }
}
