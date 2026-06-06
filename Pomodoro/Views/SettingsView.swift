import SwiftUI

struct SettingsView: View {
    @StateObject private var store = SettingsStore()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("设置")
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
                    settingsCard {
                        DurationSlider(
                            title: "工作时长",
                            systemImage: "brain.head.profile",
                            value: $store.settings.workDuration,
                            range: 5...60,
                            unit: "分钟",
                            accent: .sagePrimary
                        )
                    }

                    settingsCard {
                        DurationSlider(
                            title: "短休时长",
                            systemImage: "cup.and.saucer.fill",
                            value: $store.settings.shortBreakDuration,
                            range: 1...30,
                            unit: "分钟",
                            accent: .sageLight
                        )
                    }

                    settingsCard {
                        DurationSlider(
                            title: "长休时长",
                            systemImage: "bed.double.fill",
                            value: $store.settings.longBreakDuration,
                            range: 5...45,
                            unit: "分钟",
                            accent: .sageDark
                        )
                    }

                    settingsCard {
                        LongBreakPicker(store: store)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 20)
                .padding(.bottom, 28)
            }
        }
        .frame(width: 420, height: 500)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.creamWhite, .warmStone]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.warmCard.opacity(0.6))
            )
    }
}

// MARK: - Duration Slider

private struct DurationSlider: View {
    let title: String
    let systemImage: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let unit: String
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(accent)
                    .frame(width: 20)
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.earthText)
                Spacer()
                Text("\(value) \(unit)")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .monospacedDigit()
                    .foregroundColor(accent)
            }

            HStack(spacing: 0) {
                Text("\(range.lowerBound)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.earthText.opacity(0.3))
                Slider(value: Binding(
                    get: { Double(value) },
                    set: { value = Int($0) }
                ), in: Double(range.lowerBound)...Double(range.upperBound), step: 1)
                .tint(accent)
                Text("\(range.upperBound)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.earthText.opacity(0.3))
            }
        }
    }
}

// MARK: - Long Break Picker

private struct LongBreakPicker: View {
    @ObservedObject var store: SettingsStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "repeat")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.sageDark)
                    .frame(width: 20)
                Text("长休间隔")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.earthText)
            }

            Text("每完成 \(store.settings.longBreakInterval) 个番茄后进入长休")
                .font(.system(size: 11))
                .foregroundColor(.earthText.opacity(0.4))

            Picker("长休间隔", selection: $store.settings.longBreakInterval) {
                ForEach(2...6, id: \.self) { n in
                    Text("\(n) 个番茄").tag(n)
                }
            }
            .pickerStyle(.segmented)
            .tint(.sagePrimary)
        }
    }
}
