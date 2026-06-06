import SwiftUI

struct StatisticsView: View {
    @ObservedObject var viewModel: TimerViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("统计")
                .font(.title)
                .fontWeight(.bold)

            HStack(spacing: 20) {
                StatCard(title: "今日番茄", value: "\(viewModel.todayCount)", color: .red)
                StatCard(title: "总计番茄", value: "\(viewModel.totalPomodoros)", color: .orange)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("本周")
                    .font(.headline)

                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(viewModel.weeklyCounts, id: \.0) { day, count in
                        VStack(spacing: 4) {
                            Text("\(count)")
                                .font(.caption.monospacedDigit())
                                .foregroundColor(.secondary)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(count > 0 ? Color.red : Color.gray.opacity(0.2))
                                .frame(width: 30, height: max(CGFloat(count) * 28, 4))
                            Text(day)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.06))
            .cornerRadius(12)

            if viewModel.totalPomodoros > 0 {
                Text("历史记录")
                    .font(.headline)

                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(viewModel.recordsByDate.prefix(14), id: \.0) { date, count in
                            HStack {
                                Text(formatDate(date))
                                    .font(.body)
                                Spacer()
                                Text("\(count) 个番茄")
                                    .font(.body.monospacedDigit())
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 4)
                            Divider()
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(32)
        .frame(minWidth: 400, minHeight: 450)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日"
        return formatter.string(from: date)
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 40, weight: .bold))
                .monospacedDigit()
                .foregroundColor(color)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(color.opacity(0.08))
        .cornerRadius(12)
    }
}
