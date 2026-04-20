import SwiftUI

struct WeatherView: View {
    @ObservedObject var vm: WeatherViewModel
    @State private var showSettings = false  // NEW

    var body: some View {
        ZStack {
            // Dynamic background gradient
            LinearGradient(
                colors: vm.theme.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.7), value: vm.theme.regionName)

            // Content
            VStack(spacing: 0) {
                topBar

                // Error banner
                if let error = vm.errorMessage {
                    ErrorBanner(message: error) {
                        vm.errorMessage = nil
                    }
                    .padding(.top, 8)
                }

                Spacer()
                mainWeatherBlock
                Spacer()
                forecastCard
                cityPicker
                bottomNav
            }
        }
        .statusBarHidden(false)
        .preferredColorScheme(.dark)
        // NEW: settings sheet
        .sheet(isPresented: $showSettings) {
            SettingsView(vm: vm)
        }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            Button {
                vm.requestUserLocation()
            } label: {
                Image(systemName: "location.fill")
                    .font(.system(size: 16, weight: .medium))
            }

            Spacer()

            Text("ThemeCast")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .tracking(1.5)

            Spacer()

            HStack(spacing: 12) {
                // °F / °C toggle
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        vm.isCelsius.toggle()
                    }
                } label: {
                    Text(vm.isCelsius ? "°C" : "°F")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.white.opacity(0.2))
                        .clipShape(Capsule())
                }

                // Settings button — now opens the sheet
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16, weight: .medium))
                }
            }
        }
        .foregroundColor(.white.opacity(0.85))
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }

    // MARK: - Main weather block

    private var mainWeatherBlock: some View {
        VStack(spacing: 6) {
            Text(vm.weather?.cityName ?? vm.theme.regionName)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .tracking(3)
                .textCase(.uppercase)
                .foregroundColor(.white.opacity(0.75))

            // Floating themed icon
            Text(vm.isLoading ? "🌡️" : vm.themedMainIcon)
                .font(.system(size: 96))
                .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 6)
                .floatingAnimation()
                .padding(.vertical, 8)

            Text(vm.formattedTemperature)
                .font(.system(size: 80, weight: .thin, design: .rounded))
                .foregroundColor(.white)

            Text(vm.weather?.condition.rawValue ?? "Loading…")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.white.opacity(0.8))

            Text(vm.formattedHighLow)
                .font(.system(size: 13, weight: .light))
                .foregroundColor(.white.opacity(0.55))
                .padding(.top, 2)

            // Theme label pill
            Text("\(vm.theme.label)  \(vm.theme.emoji)")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .tracking(1.2)
                .textCase(.uppercase)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(.white.opacity(0.18))
                .clipShape(Capsule())
                .padding(.top, 10)

            // Extra stats row
            if let w = vm.weather {
                HStack(spacing: 24) {
                    WeatherStatView(icon: "humidity.fill",     value: "\(w.humidity)%",            label: "Humidity")
                    WeatherStatView(icon: "wind",               value: "\(w.windSpeed) mph",        label: "Wind")
                    WeatherStatView(icon: "thermometer.medium", value: vm.displayTemp(w.feelsLike), label: "Feels like")
                }
                .padding(.top, 14)
            }
        }
        .overlay {
            if vm.isLoading {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.4)
            }
        }
    }

    // MARK: - 5-day forecast card

    private var forecastCard: some View {
        Group {
            if let forecast = vm.weather?.forecast {
                HStack(spacing: 0) {
                    ForEach(forecast) { day in
                        ForecastDayView(
                            day: day,
                            icon: vm.theme.icon(for: day.condition)
                        )
                        if day.id != forecast.last?.id {
                            Divider()
                                .background(.white.opacity(0.15))
                                .frame(height: 44)
                        }
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 8)
                .background(.white.opacity(0.12))
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
        }
    }

    // MARK: - City picker

    private var cityPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(LocationTheme.all.indices, id: \.self) { i in
                    let t = LocationTheme.all[i]
                    Button {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            vm.selectedThemeIndex = i
                        }
                    } label: {
                        Text(t.regionName)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(vm.selectedThemeIndex == i ? .white : .white.opacity(0.6))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                vm.selectedThemeIndex == i
                                    ? .white.opacity(0.28)
                                    : .white.opacity(0.10)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.white.opacity(vm.selectedThemeIndex == i ? 0.5 : 0.15),
                                            lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }

    // MARK: - Bottom nav bar

    private var bottomNav: some View {
        HStack(spacing: 0) {
            NavButton(icon: "sun.max.fill",  label: "Today",    isActive: true)
            NavButton(icon: "calendar",       label: "Forecast", isActive: false)
            NavButton(icon: "map.fill",       label: "Map",      isActive: false)
            NavButton(icon: "gearshape.fill", label: "Settings", isActive: false)
        }
        .padding(.top, 8)
        .padding(.bottom, 20)
        .background(.black.opacity(0.25))
        .background(.ultraThinMaterial)
    }
}
