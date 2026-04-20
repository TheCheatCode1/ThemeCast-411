import SwiftUI

struct SettingsView: View {
    @ObservedObject var vm: WeatherViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Match the app's gradient background
            LinearGradient(
                colors: vm.theme.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
                    Text("Settings")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .tracking(1.5)
                        .foregroundColor(.white)

                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)

                // MARK: - Settings List
                VStack(spacing: 12) {

                    // Temperature Unit
                    SettingsRow(icon: "thermometer.medium", title: "Temperature Unit") {
                        HStack(spacing: 8) {
                            ToggleChip(label: "°F", isSelected: !vm.isCelsius) {
                                vm.isCelsius = false
                            }
                            ToggleChip(label: "°C", isSelected: vm.isCelsius) {
                                vm.isCelsius = true
                            }
                        }
                    }

                    // Current Theme Info
                    SettingsRow(icon: "paintpalette.fill", title: "Current Theme") {
                        Text("\(vm.theme.label)  \(vm.theme.emoji)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }

                    // Current Location
                    SettingsRow(icon: "location.fill", title: "Location") {
                        Button {
                            vm.requestUserLocation()
                            dismiss()
                        } label: {
                            Text("Use My Location")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.white.opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }

                    // About
                    SettingsRow(icon: "info.circle.fill", title: "App") {
                        Text("ThemeCast v1.0")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 16)

                Spacer()
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Settings Row

struct SettingsRow<Content: View>: View {
    let icon: String
    let title: String
    let content: () -> Content

    init(icon: String, title: String, @ViewBuilder content: @escaping () -> Content) {
        self.icon = icon
        self.title = title
        self.content = content
    }

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 20)

            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.85))

            Spacer()

            content()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.white.opacity(0.12))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Toggle Chip

struct ToggleChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isSelected ? .white : .white.opacity(0.5))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(isSelected ? .white.opacity(0.3) : .white.opacity(0.1))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(.white.opacity(isSelected ? 0.5 : 0.15), lineWidth: 1)
                )
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView(vm: WeatherViewModel())
}
