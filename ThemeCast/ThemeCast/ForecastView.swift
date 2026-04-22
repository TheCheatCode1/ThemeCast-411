import SwiftUI

struct ForecastView: View {
    @ObservedObject var vm: WeatherViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            LinearGradient(
                colors: vm.theme.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: Header
                HStack {
                    Text("Forecast")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .tracking(1.5)
                        .foregroundColor(.white)
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 8)

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
                .padding(.bottom, 16)

                ScrollView {
                    VStack(spacing: 12) {

                        // MARK: Hourly section
                        if let hourly = vm.weather?.hourlyForecast, !hourly.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("NEXT 24 HOURS")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.5))
                                    .tracking(1.5)
                                    .padding(.horizontal, 4)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 4) {
                                        ForEach(hourly) { hour in
                                            HourlyCell(hour: hour, icon: vm.theme.icon(for: hour.condition), vm: vm)
                                        }
                                    }
                                    .padding(.horizontal, 4)
                                }
                            }
                            .padding(14)
                            .background(.white.opacity(0.12))
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        // MARK: 5-day section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("5-DAY FORECAST")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(.white.opacity(0.5))
                                .tracking(1.5)
                                .padding(.horizontal, 4)

                            if let forecast = vm.weather?.forecast {
                                VStack(spacing: 8) {
                                    ForEach(forecast) { day in
                                        ForecastRowView(day: day, icon: vm.theme.icon(for: day.condition), vm: vm)
                                    }
                                }
                            } else {
                                ProgressView().tint(.white).frame(maxWidth: .infinity)
                            }
                        }
                        .padding(14)
                        .background(.white.opacity(0.12))
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        // MARK: Sunrise / Sunset section
                        if let w = vm.weather {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("SUN")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.5))
                                    .tracking(1.5)
                                    .padding(.horizontal, 4)

                                HStack(spacing: 0) {
                                    SunTimeView(icon: "sunrise.fill", label: "Sunrise", time: w.sunrise)
                                    Divider().background(.white.opacity(0.2)).frame(height: 44)
                                    SunTimeView(icon: "sunset.fill",  label: "Sunset",  time: w.sunset)
                                }
                                .padding(.vertical, 8)
                            }
                            .padding(14)
                            .background(.white.opacity(0.12))
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
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
            Text(day.dayName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 40, alignment: .leading)

            Text(icon)
                .font(.system(size: 28))
                .frame(width: 44)

            Text(day.condition.rawValue)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.white.opacity(0.7))

            Spacer()

            HStack(spacing: 12) {
                VStack(spacing: 2) {
                    Text("H").font(.system(size: 9, weight: .medium)).foregroundColor(.white.opacity(0.5))
                    Text(vm.displayTemp(day.high)).font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                }
                VStack(spacing: 2) {
                    Text("L").font(.system(size: 9, weight: .medium)).foregroundColor(.white.opacity(0.5))
                    Text(vm.displayTemp(day.low)).font(.system(size: 15, weight: .light)).foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ForecastView(vm: WeatherViewModel())
}
