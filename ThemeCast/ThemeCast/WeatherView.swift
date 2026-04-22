import SwiftUI

struct WeatherView: View {
    @ObservedObject var vm: WeatherViewModel
    @State private var showSettings = false
    @State private var showForecast = false
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: vm.theme.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.7), value: vm.theme.regionName)

            // Pull to refresh wraps the scrollable content
            ScrollView {
                VStack(spacing: 0) {
                    // Spacer to push content below fixed top bar + search
                    Color.clear.frame(height: 110)

                    if let error = vm.errorMessage {
                        ErrorBanner(message: error) { vm.errorMessage = nil }
                            .padding(.top, 8)
                    }

                    mainWeatherBlock
                        .padding(.top, 12)

                    // Hourly forecast strip — NEW
                    hourlyStrip

                    forecastCard
                    sunCard           // NEW
                    cityPicker
                    bottomNav
                }
            }
            .refreshable {
                await vm.refresh()  // Pull to refresh
            }

            // Fixed overlay: top bar + search always on top
            VStack(spacing: 0) {
                topBar
                searchField
            }

            // Search results overlay
            if !vm.searchResults.isEmpty {
                searchResultsOverlay
            }
        }
        .statusBarHidden(false)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showSettings) { SettingsView(vm: vm) }
        .sheet(isPresented: $showForecast) { ForecastView(vm: vm) }
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            Button { vm.requestUserLocation() } label: {
                Image(systemName: "location.fill")
                    .font(.system(size: 16, weight: .medium))
            }
            Spacer()
            Text("ThemeCast")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .tracking(1.5)
            Spacer()
            HStack(spacing: 12) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { vm.isCelsius.toggle() }
                } label: {
                    Text(vm.isCelsius ? "°C" : "°F")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.white.opacity(0.2))
                        .clipShape(Capsule())
                }
                Button { showSettings = true } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 16, weight: .medium))
                }
            }
        }
        .foregroundColor(.white.opacity(0.85))
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }

    // MARK: - Search field

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.6))
                .font(.system(size: 14))
            TextField("Search city...", text: $vm.searchText)
                .foregroundColor(.white)
                .font(.system(size: 14))
                .autocorrectionDisabled()
                .focused($isSearchFocused)
                .onChange(of: vm.searchText) { vm.searchCity() }
                .onSubmit { vm.searchCity() }
            if !vm.searchText.isEmpty {
                Button {
                    vm.searchText = ""
                    vm.searchResults = []
                    isSearchFocused = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 14))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
        .padding(.top, 10)
    }

    // MARK: - Search results overlay

    private var searchResultsOverlay: some View {
        VStack {
            Spacer().frame(height: 110)
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(vm.searchResults) { city in
                        Button {
                            vm.selectCity(city)
                            isSearchFocused = false
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(city.name)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.white)
                                    Text(city.admin.isEmpty ? city.country : "\(city.admin), \(city.country)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                Spacer()
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        if city.id != vm.searchResults.last?.id {
                            Divider().background(.white.opacity(0.15))
                        }
                    }
                }
            }
            .frame(maxHeight: 300)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 4)
            .padding(.horizontal, 16)
            Spacer()
        }
        .zIndex(10)
        .transition(.opacity)
    }

    // MARK: - Main weather block

    private var mainWeatherBlock: some View {
        VStack(spacing: 6) {
            Text(vm.weather?.cityName ?? vm.theme.regionName)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .tracking(3)
                .textCase(.uppercase)
                .foregroundColor(.white.opacity(0.75))

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

            if let w = vm.weather {
                // Stats row — now includes UV index
                HStack(spacing: 16) {
                    WeatherStatView(icon: "humidity.fill",      value: "\(w.humidity)%",                          label: "Humidity")
                    WeatherStatView(icon: "wind",                value: "\(w.windSpeed) mph",                     label: "Wind")
                    WeatherStatView(icon: "thermometer.medium", value: vm.displayTemp(w.feelsLike),               label: "Feels like")
                    WeatherStatView(icon: "sun.max.fill",        value: "UV \(w.uvIndex)",                        label: OpenMeteoWeatherService.uvLabel(w.uvIndex))
                }
                .padding(.top, 14)
            }
        }
        .overlay {
            if vm.isLoading {
                ProgressView().tint(.white).scaleEffect(1.4)
            }
        }
    }

    // MARK: - Hourly forecast strip (NEW)

    private var hourlyStrip: some View {
        Group {
            if let hourly = vm.weather?.hourlyForecast, !hourly.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("HOURLY")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                        .tracking(1.5)
                        .padding(.horizontal, 24)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(hourly) { hour in
                                HourlyCell(hour: hour, icon: vm.theme.icon(for: hour.condition), vm: vm)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 12)
                .background(.white.opacity(0.10))
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
        }
    }

    // MARK: - Sunrise / Sunset card (NEW)

    private var sunCard: some View {
        Group {
            if let w = vm.weather {
                HStack(spacing: 0) {
                    SunTimeView(icon: "sunrise.fill", label: "Sunrise", time: w.sunrise)
                    Divider().background(.white.opacity(0.15)).frame(height: 44)
                    SunTimeView(icon: "sunset.fill",  label: "Sunset",  time: w.sunset)
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

    // MARK: - 5-day forecast card

    private var forecastCard: some View {
        Group {
            if let forecast = vm.weather?.forecast {
                HStack(spacing: 0) {
                    ForEach(forecast) { day in
                        ForecastDayView(day: day, icon: vm.theme.icon(for: day.condition))
                        if day.id != forecast.last?.id {
                            Divider().background(.white.opacity(0.15)).frame(height: 44)
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
                        withAnimation(.easeInOut(duration: 0.4)) { vm.selectedThemeIndex = i }
                    } label: {
                        Text(t.regionName)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(vm.selectedThemeIndex == i ? .white : .white.opacity(0.6))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(vm.selectedThemeIndex == i ? .white.opacity(0.28) : .white.opacity(0.10))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.white.opacity(vm.selectedThemeIndex == i ? 0.5 : 0.15), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
    }

    // MARK: - Bottom nav

    private var bottomNav: some View {
        HStack(spacing: 0) {
            NavButton(icon: "sun.max.fill",  label: "Today",    isActive: true)
            NavButton(icon: "calendar",       label: "Forecast", isActive: false) { showForecast = true }
            NavButton(icon: "map.fill",       label: "Map",      isActive: false)
            NavButton(icon: "gearshape.fill", label: "Settings", isActive: false) { showSettings = true }
        }
        .padding(.top, 8)
        .padding(.bottom, 20)
        .background(.black.opacity(0.25))
        .background(.ultraThinMaterial)
    }
}

// MARK: - Hourly Cell (NEW)

struct HourlyCell: View {
    let hour: HourForecast
    let icon: String
    @ObservedObject var vm: WeatherViewModel

    var body: some View {
        VStack(spacing: 6) {
            Text(hour.hour)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            Text(icon)
                .font(.system(size: 20))
            Text(vm.displayTemp(hour.temperature))
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
        }
        .frame(width: 56)
        .padding(.vertical, 8)
        .background(.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Sun Time View (NEW)

struct SunTimeView: View {
    let icon: String
    let label: String
    let time: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.yellow.opacity(0.85))
            Text(time)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
}
