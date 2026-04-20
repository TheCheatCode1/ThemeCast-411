import SwiftUI

struct ForecastView: View {
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
                    Text("5-Day Forecast")
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

                // City + theme pill
                VStack(spacing: 6) {
                    Text(vm.weather?.cityName ?? vm.theme.regionName)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .tracking(3)
                        .textCase(.uppercase)
                        .foregroundColor(.white.opacity(0.7))

                    Text("\(vm.theme.label)  \(vm.theme.emoji)")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .tracking(1.2)
                        .textCase(.uppercase)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(.white.opacity(0.18))
                        .clipShape(Capsule())
                }
                .padding(.bottom, 24)

                // MARK: - Forecast Cards
                if let forecast = vm.weather?.forecast {
                    VStack(spacing: 12) {
                        ForEach(forecast) { day in
                            ForecastRowView(
                                day: day,
                                icon: vm.theme.icon(for: day.condition),
                                vm: vm
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                } else {
                    Spacer()
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.4)
                    Spacer()
                }

                Spacer()
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Forecast Row

struct ForecastRowView: View {
    let day: DayForecast
    let icon: String
    @ObservedObject var vm: WeatherViewModel

    var body: some View {
        HStack {
            // Day name
            Text(day.dayName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 40, alignment: .leading)

            // Themed icon
            Text(icon)
                .font(.system(size: 28))
                .frame(width: 44)

            // Condition
            Text(day.condition.rawValue)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.white.opacity(0.7))

            Spacer()

            // High / Low
            HStack(spacing: 12) {
                VStack(spacing: 2) {
                    Text("H")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                    Text(vm.displayTemp(day.high))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(spacing: 2) {
                    Text("L")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                    Text(vm.displayTemp(day.low))
                        .font(.system(size: 15, weight: .light))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.white.opacity(0.12))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Preview

#Preview {
    ForecastView(vm: WeatherViewModel())
}
