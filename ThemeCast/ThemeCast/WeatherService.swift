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

// MARK: - City Search Result

struct CitySearchResult: Identifiable, Hashable {
    let id: Int
    let name: String
    let country: String
    let admin: String  // state/region
    let latitude: Double
    let longitude: Double

    var displayName: String {
        if admin.isEmpty {
            return "\(name), \(country)"
        }
        return "\(name), \(admin), \(country)"
    }
}

// MARK: - Weather Service Protocol

protocol WeatherServiceProtocol: Sendable {
    func fetchWeather(for location: CLLocation, cityName: String) async throws -> WeatherData
    func searchCities(query: String) async throws -> [CitySearchResult]
}

// MARK: - Open-Meteo Weather Service (free, no API key needed)

final class OpenMeteoWeatherService: WeatherServiceProtocol {

    func fetchWeather(for location: CLLocation, cityName: String) async throws -> WeatherData {
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min&temperature_unit=fahrenheit&wind_speed_unit=mph&timezone=auto&forecast_days=6"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]

        let current = json["current"] as? [String: Any] ?? [:]
        let daily = json["daily"] as? [String: Any] ?? [:]

        let temperature = Int(current["temperature_2m"] as? Double ?? 0)
        let feelsLike = Int(current["apparent_temperature"] as? Double ?? 0)
        let humidity = Int(current["relative_humidity_2m"] as? Double ?? 0)
        let windSpeed = Int(current["wind_speed_10m"] as? Double ?? 0)
        let weatherCode = current["weather_code"] as? Int ?? 0

        let highs = daily["temperature_2m_max"] as? [Double] ?? []
        let lows = daily["temperature_2m_min"] as? [Double] ?? []
        let dailyCodes = daily["weather_code"] as? [Int] ?? []
        let dates = daily["time"] as? [String] ?? []

        let todayHigh = highs.first.map { Int($0) } ?? temperature
        let todayLow = lows.first.map { Int($0) } ?? temperature

        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "yyyy-MM-dd"
        let nameFormatter = DateFormatter()
        nameFormatter.dateFormat = "EEE"

        var forecastDays: [DayForecast] = []
        // Skip index 0 (today) and take next 5 days
        for i in 1..<min(6, dates.count) {
            let dayName: String
            if let date = dayFormatter.date(from: dates[i]) {
                dayName = nameFormatter.string(from: date)
            } else {
                dayName = "—"
            }
            forecastDays.append(DayForecast(
                dayName: dayName,
                condition: Self.mapWeatherCode(i < dailyCodes.count ? dailyCodes[i] : 0),
                high: i < highs.count ? Int(highs[i]) : 0,
                low: i < lows.count ? Int(lows[i]) : 0
            ))
        }

        return WeatherData(
            temperature: temperature,
            feelsLike: feelsLike,
            high: todayHigh,
            low: todayLow,
            condition: Self.mapWeatherCode(weatherCode),
            humidity: humidity,
            windSpeed: windSpeed,
            forecast: forecastDays,
            cityName: cityName
        )
    }

    func searchCities(query: String) async throws -> [CitySearchResult] {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://geocoding-api.open-meteo.com/v1/search?name=\(encoded)&count=8&language=en&format=json") else {
            return []
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        let results = json["results"] as? [[String: Any]] ?? []

        return results.compactMap { item in
            guard let id = item["id"] as? Int,
                  let name = item["name"] as? String,
                  let lat = item["latitude"] as? Double,
                  let lon = item["longitude"] as? Double else { return nil }
            let country = item["country"] as? String ?? ""
            let admin = item["admin1"] as? String ?? ""
            return CitySearchResult(id: id, name: name, country: country, admin: admin, latitude: lat, longitude: lon)
        }
    }

    private static func mapWeatherCode(_ code: Int) -> WeatherCondition {
        switch code {
        case 0, 1:          return .sunny
        case 2:             return .partlyCloudy
        case 3:             return .cloudy
        case 45, 48:        return .foggy
        case 51...57:       return .rainy
        case 61...67:       return .rainy
        case 71...77:       return .snowy
        case 80...82:       return .rainy
        case 85, 86:        return .snowy
        case 95:            return .stormy
        case 96, 99:        return .stormy
        default:            return .partlyCloudy
        }
    }
}
