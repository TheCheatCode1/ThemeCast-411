import Foundation
import CoreLocation

// MARK: - Data Models

struct WeatherData {
    let temperature: Int          // Fahrenheit
    let feelsLike: Int
    let high: Int
    let low: Int
    let condition: WeatherCondition
    let humidity: Int             // percent
    let windSpeed: Int            // mph
    let forecast: [DayForecast]
    let cityName: String
}

struct DayForecast: Identifiable {
    let id = UUID()
    let dayName: String           // "Mon", "Tue" …
    let condition: WeatherCondition
    let high: Int
    let low: Int
}

// MARK: - Weather Service Protocol

protocol WeatherServiceProtocol {
    func fetchWeather(for location: CLLocation, cityName: String) async throws -> WeatherData
}

// MARK: - Mock Weather Service (replace with WeatherKit in production)

final class MockWeatherService: WeatherServiceProtocol {

    func fetchWeather(for location: CLLocation, cityName: String) async throws -> WeatherData {
        try await Task.sleep(nanoseconds: 800_000_000)
        return mockData(cityName: cityName)
    }

    private func mockData(cityName: String) -> WeatherData {
        switch cityName {
        case "Los Angeles":
            return WeatherData(
                temperature: 74, feelsLike: 76, high: 79, low: 62,
                condition: .sunny, humidity: 38, windSpeed: 8,
                forecast: [
                    DayForecast(dayName: "Mon", condition: .sunny,        high: 77, low: 63),
                    DayForecast(dayName: "Tue", condition: .sunny,        high: 75, low: 61),
                    DayForecast(dayName: "Wed", condition: .partlyCloudy, high: 70, low: 59),
                    DayForecast(dayName: "Thu", condition: .sunny,        high: 78, low: 62),
                    DayForecast(dayName: "Fri", condition: .sunny,        high: 80, low: 64),
                ],
                cityName: "Los Angeles"
            )
        case "Seattle":
            return WeatherData(
                temperature: 52, feelsLike: 49, high: 55, low: 46,
                condition: .rainy, humidity: 82, windSpeed: 14,
                forecast: [
                    DayForecast(dayName: "Mon", condition: .rainy,        high: 51, low: 45),
                    DayForecast(dayName: "Tue", condition: .cloudy,       high: 53, low: 46),
                    DayForecast(dayName: "Wed", condition: .partlyCloudy, high: 55, low: 47),
                    DayForecast(dayName: "Thu", condition: .rainy,        high: 49, low: 43),
                    DayForecast(dayName: "Fri", condition: .partlyCloudy, high: 58, low: 48),
                ],
                cityName: "Seattle"
            )
        case "New York":
            return WeatherData(
                temperature: 61, feelsLike: 58, high: 65, low: 52,
                condition: .partlyCloudy, humidity: 55, windSpeed: 18,
                forecast: [
                    DayForecast(dayName: "Mon", condition: .partlyCloudy, high: 63, low: 53),
                    DayForecast(dayName: "Tue", condition: .sunny,        high: 68, low: 55),
                    DayForecast(dayName: "Wed", condition: .rainy,        high: 58, low: 50),
                    DayForecast(dayName: "Thu", condition: .windy,        high: 55, low: 48),
                    DayForecast(dayName: "Fri", condition: .sunny,        high: 70, low: 57),
                ],
                cityName: "New York"
            )
        case "Alaska":
            return WeatherData(
                temperature: 14, feelsLike: 4, high: 18, low: 4,
                condition: .snowy, humidity: 70, windSpeed: 22,
                forecast: [
                    DayForecast(dayName: "Mon", condition: .snowy,  high: 12, low: 2),
                    DayForecast(dayName: "Tue", condition: .cloudy, high: 16, low: 5),
                    DayForecast(dayName: "Wed", condition: .snowy,  high: 10, low: 0),
                    DayForecast(dayName: "Thu", condition: .windy,  high: 8,  low: -2),
                    DayForecast(dayName: "Fri", condition: .cloudy, high: 20, low: 7),
                ],
                cityName: "Alaska"
            )
        case "Arizona":
            return WeatherData(
                temperature: 97, feelsLike: 105, high: 104, low: 80,
                condition: .sunny, humidity: 12, windSpeed: 6,
                forecast: [
                    DayForecast(dayName: "Mon", condition: .sunny,        high: 99,  low: 81),
                    DayForecast(dayName: "Tue", condition: .sunny,        high: 101, low: 83),
                    DayForecast(dayName: "Wed", condition: .sunny,        high: 98,  low: 80),
                    DayForecast(dayName: "Thu", condition: .partlyCloudy, high: 94,  low: 78),
                    DayForecast(dayName: "Fri", condition: .sunny,        high: 102, low: 82),
                ],
                cityName: "Arizona"
            )

        // NEW: Miami
        case "Miami":
            return WeatherData(
                temperature: 88, feelsLike: 96, high: 92, low: 78,
                condition: .sunny, humidity: 85, windSpeed: 12,
                forecast: [
                    DayForecast(dayName: "Mon", condition: .sunny,        high: 90, low: 79),
                    DayForecast(dayName: "Tue", condition: .stormy,       high: 85, low: 76),
                    DayForecast(dayName: "Wed", condition: .rainy,        high: 83, low: 75),
                    DayForecast(dayName: "Thu", condition: .sunny,        high: 91, low: 78),
                    DayForecast(dayName: "Fri", condition: .partlyCloudy, high: 89, low: 77),
                ],
                cityName: "Miami"
            )

        // NEW: Chicago
        case "Chicago":
            return WeatherData(
                temperature: 45, feelsLike: 38, high: 50, low: 36,
                condition: .windy, humidity: 62, windSpeed: 28,
                forecast: [
                    DayForecast(dayName: "Mon", condition: .windy,        high: 47, low: 34),
                    DayForecast(dayName: "Tue", condition: .cloudy,       high: 49, low: 37),
                    DayForecast(dayName: "Wed", condition: .rainy,        high: 44, low: 33),
                    DayForecast(dayName: "Thu", condition: .snowy,        high: 38, low: 28),
                    DayForecast(dayName: "Fri", condition: .partlyCloudy, high: 52, low: 38),
                ],
                cityName: "Chicago"
            )

        default:
            return WeatherData(
                temperature: 68, feelsLike: 66, high: 72, low: 58,
                condition: .partlyCloudy, humidity: 50, windSpeed: 10,
                forecast: [
                    DayForecast(dayName: "Mon", condition: .sunny,        high: 70, low: 58),
                    DayForecast(dayName: "Tue", condition: .partlyCloudy, high: 68, low: 57),
                    DayForecast(dayName: "Wed", condition: .cloudy,       high: 64, low: 55),
                    DayForecast(dayName: "Thu", condition: .rainy,        high: 60, low: 52),
                    DayForecast(dayName: "Fri", condition: .sunny,        high: 72, low: 59),
                ],
                cityName: cityName
            )
        }
    }
}

// MARK: - WeatherKit adapter (stubbed — enable when WeatherKit entitlement is added)
/*
import WeatherKit

final class WeatherKitService: WeatherServiceProtocol {
    private let service = WeatherService.shared

    func fetchWeather(for location: CLLocation, cityName: String) async throws -> WeatherData {
        let weather = try await service.weather(for: location)
        let current = weather.currentWeather
        let daily   = weather.dailyForecast.forecast.prefix(5)

        return WeatherData(
            temperature: Int(current.temperature.converted(to: .fahrenheit).value),
            feelsLike:   Int(current.apparentTemperature.converted(to: .fahrenheit).value),
            high:        Int(daily.first?.highTemperature.converted(to: .fahrenheit).value ?? 0),
            low:         Int(daily.first?.lowTemperature.converted(to: .fahrenheit).value ?? 0),
            condition:   mapCondition(current.condition),
            humidity:    Int(current.humidity * 100),
            windSpeed:   Int(current.wind.speed.converted(to: .milesPerHour).value),
            forecast:    daily.enumerated().map { i, d in
                DayForecast(
                    dayName:   shortDayName(d.date),
                    condition: mapCondition(d.condition),
                    high:      Int(d.highTemperature.converted(to: .fahrenheit).value),
                    low:       Int(d.lowTemperature.converted(to: .fahrenheit).value)
                )
            },
            cityName: cityName
        )
    }

    private func mapCondition(_ c: WeatherCondition) -> WeatherCondition { ... }
    private func shortDayName(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "EEE"; return f.string(from: date)
    }
}
*/
