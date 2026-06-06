import SwiftUI

struct SettingsView: View {
    @StateObject private var store = SettingsStore()

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("设置")
                .font(.title)
                .fontWeight(.bold)

            DurationSlider(
                title: "工作时长",
                systemImage: "brain.head.profile",
                value: $store.settings.workDuration,
                range: 5...60,
                unit: "分钟"
            )

            DurationSlider(
                title: "短休时长",
                systemImage: "cup.and.saucer.fill",
                value: $store.settings.shortBreakDuration,
                range: 1...30,
                unit: "分钟"
            )

            DurationSlider(
                title: "长休时长",
                systemImage: "bed.double.fill",
                value: $store.settings.longBreakDuration,
                range: 5...45,
                unit: "分钟"
            )

            VStack(alignment: .leading, spacing: 6) {
                Label("长休间隔", systemImage: "repeat")
                    .font(.headline)
                Text("每完成 \(store.settings.longBreakInterval) 个番茄后进入长休")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Picker("长休间隔", selection: $store.settings.longBreakInterval) {
                    ForEach(2...6, id: \.self) { n in
                        Text("\(n) 个番茄").tag(n)
                    }
                }
                .pickerStyle(.segmented)
            }

            Spacer()
        }
        .padding(32)
        .frame(minWidth: 400, minHeight: 450)
    }
}

private struct DurationSlider: View {
    let title: String
    let systemImage: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: systemImage)
                .font(.headline)

            HStack {
                Slider(value: Binding(
                    get: { Double(value) },
                    set: { value = Int($0) }
                ), in: Double(range.lowerBound)...Double(range.upperBound), step: 1)
                Text("\(value) \(unit)")
                    .font(.title3.monospacedDigit())
                    .frame(width: 70, alignment: .trailing)
                    .foregroundColor(.secondary)
            }
        }
    }
}
