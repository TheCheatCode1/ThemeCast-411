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

    // MARK: Demo mode (city picker)
    @Published var selectedThemeIndex: Int = 0 {
        didSet { loadDemo() }
    }

    // MARK: Dependencies
    private let locationManager: LocationManager
    private let weatherService: WeatherServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: Init
    init(locationManager: LocationManager = LocationManager(),
         weatherService: WeatherServiceProtocol = MockWeatherService()) {
        self.locationManager = locationManager
        self.weatherService  = weatherService

        // React to placemark changes from the location manager
        locationManager.$placemark
            .compactMap { $0 }
            .sink { [weak self] placemark in
                Task { await self?.load(placemark: placemark) }
            }
            .store(in: &cancellables)

        // Forward location errors
        locationManager.$error
            .compactMap { $0?.errorDescription }
            .assign(to: &$errorMessage)

        // Load demo data on first launch
        loadDemo()
    }

    // MARK: - Public API

    func requestUserLocation() {
        locationManager.requestLocation()
    }

    // MARK: - Private

    private func load(placemark: CLPlacemark) async {
        guard let location = placemark.location else { return }
        let detectedTheme = LocationTheme.theme(for: placemark)
        let cityName = detectedTheme.regionName

        isLoading = true
        errorMessage = nil

        do {
            let data = try await weatherService.fetchWeather(for: location, cityName: cityName)
            withAnimation(.easeInOut(duration: 0.6)) {
                self.weather = data
                self.theme   = detectedTheme
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func loadDemo() {
        let demoTheme = LocationTheme.all[selectedThemeIndex]
        let dummyLocation = CLLocation(latitude: 34.05, longitude: -118.24)

        isLoading = true
        Task {
            do {
                let data = try await weatherService.fetchWeather(for: dummyLocation,
                                                                 cityName: demoTheme.regionName)
                withAnimation(.easeInOut(duration: 0.6)) {
                    self.weather = data
                    self.theme   = demoTheme
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
        return "\(w.temperature)°"
    }

    var formattedHighLow: String {
        guard let w = weather else { return "" }
        return "H: \(w.high)°  ·  L: \(w.low)°"
    }

    var themedMainIcon: String {
        guard let w = weather else { return theme.emoji }
        return theme.icon(for: w.condition)
    }
}
