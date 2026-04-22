import SwiftUI
import CoreLocation
import Combine

@MainActor
final class WeatherViewModel: ObservableObject {

    // MARK: Published UI state
    @Published var weather: WeatherData?
    @Published var theme: LocationTheme = .losAngeles
    @Published var isLoading = false
    @Published var errorMessage: String?

    // °F / °C toggle
    @Published var isCelsius: Bool = false

    // City search
    @Published var searchText: String = ""
    @Published var searchResults: [CitySearchResult] = []
    @Published var isSearching = false

    // Theme picker
    @Published var selectedThemeIndex: Int = 0 {
        didSet { loadThemeCity(LocationTheme.all[selectedThemeIndex]) }
    }

    // MARK: Dependencies
    private let locationManager: LocationManager
    private let weatherService: WeatherServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?
    private var lastLocation: CLLocation?
    private var lastCityName: String?
    private var lastTheme: LocationTheme?

    // MARK: Init
    init(locationManager: LocationManager? = nil,
         weatherService: WeatherServiceProtocol = OpenMeteoWeatherService()) {
        let locationManager = locationManager ?? LocationManager()
        self.locationManager = locationManager
        self.weatherService  = weatherService

        locationManager.$placemark
            .compactMap { $0 }
            .sink { [weak self] placemark in
                Task { await self?.load(placemark: placemark) }
            }
            .store(in: &cancellables)

        locationManager.$error
            .map { $0?.errorDescription }
            .assign(to: &$errorMessage)

        loadThemeCity(LocationTheme.all[0])
    }

    // MARK: - Public API

    func requestUserLocation() {
        locationManager.requestLocation()
    }

    func searchCity() {
        let query = searchText.trimmingCharacters(in: .whitespaces)
        guard query.count >= 2 else { searchResults = []; return }

        searchTask?.cancel()
        searchTask = Task {
            isSearching = true
            do {
                let results = try await weatherService.searchCities(query: query)
                if !Task.isCancelled { searchResults = results }
            } catch {
                if !Task.isCancelled { searchResults = [] }
            }
            isSearching = false
        }
    }

    func selectCity(_ city: CitySearchResult) {
        searchText = ""
        searchResults = []
        let location = CLLocation(latitude: city.latitude, longitude: city.longitude)
        let detectedTheme = LocationTheme.theme(forLatitude: city.latitude)
        loadWeather(for: location, cityName: city.name, theme: detectedTheme)
    }

    // Pull to refresh — re-fetches current weather
    func refresh() async {
        guard let location = lastLocation,
              let cityName = lastCityName,
              let theme    = lastTheme else { return }
        isLoading = true
        errorMessage = nil
        do {
            let data = try await weatherService.fetchWeather(for: location, cityName: cityName)
            withAnimation(.easeInOut(duration: 0.6)) {
                self.weather = data
                self.theme   = theme
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func displayTemp(_ fahrenheit: Int) -> String {
        if isCelsius {
            let celsius = (fahrenheit - 32) * 5 / 9
            return "\(celsius)°C"
        } else {
            return "\(fahrenheit)°F"
        }
    }

    // MARK: - Private

    private func load(placemark: CLPlacemark) async {
        guard let location = placemark.location else { return }
        let detectedTheme = LocationTheme.theme(for: placemark)
        let cityName = placemark.locality ?? detectedTheme.regionName
        loadWeather(for: location, cityName: cityName, theme: detectedTheme)
    }

    private func loadThemeCity(_ themeEntry: LocationTheme) {
        let location = CLLocation(latitude: themeEntry.coordinate.latitude,
                                  longitude: themeEntry.coordinate.longitude)
        loadWeather(for: location, cityName: themeEntry.regionName, theme: themeEntry)
    }

    func loadWeather(for location: CLLocation, cityName: String, theme: LocationTheme) {
        // Save for pull-to-refresh
        lastLocation = location
        lastCityName = cityName
        lastTheme    = theme

        isLoading = true
        errorMessage = nil
        Task {
            do {
                let data = try await weatherService.fetchWeather(for: location, cityName: cityName)
                withAnimation(.easeInOut(duration: 0.6)) {
                    self.weather = data
                    self.theme   = theme
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    // MARK: - Helpers

    var formattedTemperature: String {
        guard let w = weather else { return "--°" }
        return displayTemp(w.temperature)
    }

    var formattedHighLow: String {
        guard let w = weather else { return "" }
        return "H: \(displayTemp(w.high))  ·  L: \(displayTemp(w.low))"
    }

    var themedMainIcon: String {
        guard let w = weather else { return theme.emoji }
        return theme.icon(for: w.condition)
    }
}
