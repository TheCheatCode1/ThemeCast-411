import Foundation
import CoreLocation

// MARK: - Data Models

struct WeatherData {
    let temperature: Int
    let feelsLike: Int
    let high: Int
    let low: Int
    let condition: WeatherCondition
    let humidity: Int
    let windSpeed: Int
    let uvIndex: Int
    let sunrise: String
    let sunset: String
    let forecast: [DayForecast]
    let hourlyForecast: [HourForecast]
    let cityName: String
}

struct DayForecast: Identifiable {
    let id = UUID()
    let dayName: String
    let condition: WeatherCondition
    let high: Int
    let low: Int
}

struct HourForecast: Identifiable {
    let id = UUID()
    let hour: String
    let condition: WeatherCondition
    let temperature: Int
}

// MARK: - City Search Result

struct CitySearchResult: Identifiable, Hashable {
    let id: Int
    let name: String
    let country: String
    let admin: String
    let latitude: Double
    let longitude: Double

    var displayName: String {
        if admin.isEmpty { return "\(name), \(country)" }
        return "\(name), \(admin), \(country)"
    }
}

// MARK: - Weather Service Protocol

protocol WeatherServiceProtocol: Sendable {
    func fetchWeather(for location: CLLocation, cityName: String) async throws -> WeatherData
    func searchCities(query: String) async throws -> [CitySearchResult]
}

// MARK: - Open-Meteo Weather Service

final class OpenMeteoWeatherService: WeatherServiceProtocol {

    // MARK: - Cached formatters (DateFormatter is expensive to create)

    private static let dayParseFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(identifier: "UTC")
        return f
    }()

    private static let dayNameFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateFormat = "EEE"
        f.timeZone = TimeZone(identifier: "UTC")
        return f
    }()

    private static let sunParseFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd'T'HH:mm"
        return f
    }()

    private static let sunDisplayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()

    // MARK: - fetchWeather

    func fetchWeather(for location: CLLocation, cityName: String) async throws -> WeatherData {
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude

        let urlString = "https://api.open-meteo.com/v1/forecast"
            + "?latitude=\(lat)&longitude=\(lon)"
            + "&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,uv_index"
            + "&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset"
            + "&hourly=temperature_2m,weather_code"
            + "&temperature_unit=fahrenheit"
            + "&wind_speed_unit=mph"
            + "&timezone=auto"
            + "&forecast_days=6"

        guard let url = URL(string: urlString) else { throw URLError(.badURL) }

        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]

        let current = json["current"] as? [String: Any] ?? [:]
        let daily   = json["daily"]   as? [String: Any] ?? [:]
        let hourly  = json["hourly"]  as? [String: Any] ?? [:]

        let temperature = Int(current["temperature_2m"]      as? Double ?? 0)
        let feelsLike   = Int(current["apparent_temperature"] as? Double ?? 0)
        let humidity    = Int(current["relative_humidity_2m"] as? Double ?? 0)
        let windSpeed   = Int(current["wind_speed_10m"]       as? Double ?? 0)
        let weatherCode =    current["weather_code"]          as? Int    ?? 0
        let uvIndex     = Int((current["uv_index"]            as? Double ?? 0).rounded())

        let highs      = daily["temperature_2m_max"] as? [Double] ?? []
        let lows       = daily["temperature_2m_min"] as? [Double] ?? []
        let dailyCodes = daily["weather_code"]       as? [Int]    ?? []
        let dates      = daily["time"]               as? [String] ?? []
        let sunrises   = daily["sunrise"]            as? [String] ?? []
        let sunsets    = daily["sunset"]             as? [String] ?? []

        let todayHigh = highs.first.map { Int($0) } ?? temperature
        let todayLow  = lows.first.map  { Int($0) } ?? temperature
        let sunrise   = Self.formatSunTime(sunrises.first ?? "")
        let sunset    = Self.formatSunTime(sunsets.first  ?? "")

        var forecastDays: [DayForecast] = []
        for i in 1..<min(6, dates.count) {
            let dayName = Self.dayParseFormatter.date(from: dates[i])
                .map { Self.dayNameFormatter.string(from: $0) } ?? "—"
            forecastDays.append(DayForecast(
                dayName:   dayName,
                condition: Self.mapWeatherCode(i < dailyCodes.count ? dailyCodes[i] : 0),
                high:      i < highs.count ? Int(highs[i]) : 0,
                low:       i < lows.count  ? Int(lows[i])  : 0
            ))
        }

        // Hourly — use the location's timezone so hours display correctly for any searched city
        let tzIdentifier = json["timezone"] as? String ?? "UTC"
        let locationTZ = TimeZone(identifier: tzIdentifier) ?? .current

        let isoFormatter = DateFormatter()
        isoFormatter.locale = Locale(identifier: "en_US_POSIX")
        isoFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        isoFormatter.timeZone = locationTZ

        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "h a"
        hourFormatter.timeZone = locationTZ

        let hourlyTemps = hourly["temperature_2m"] as? [Double] ?? []
        let hourlyCodes = hourly["weather_code"]   as? [Int]    ?? []
        let hourlyTimes = hourly["time"]           as? [String] ?? []

        // Find the first entry at or within the last 30 minutes
        let lookbackDate = Date().addingTimeInterval(-1800)
        var startIndex = 0
        for (i, timeStr) in hourlyTimes.enumerated() {
            if let t = isoFormatter.date(from: timeStr), t >= lookbackDate {
                startIndex = i
                break
            }
        }

        var hourlyForecast: [HourForecast] = []
        for i in startIndex..<min(startIndex + 24, hourlyTemps.count) {
            let timeStr   = i < hourlyTimes.count ? hourlyTimes[i] : ""
            let hourLabel = isoFormatter.date(from: timeStr)
                .map { hourFormatter.string(from: $0) } ?? "—"
            hourlyForecast.append(HourForecast(
                hour:        hourLabel,
                condition:   Self.mapWeatherCode(i < hourlyCodes.count ? hourlyCodes[i] : 0),
                temperature: Int(hourlyTemps[i])
            ))
        }

        return WeatherData(
            temperature:    temperature,
            feelsLike:      feelsLike,
            high:           todayHigh,
            low:            todayLow,
            condition:      Self.mapWeatherCode(weatherCode),
            humidity:       humidity,
            windSpeed:      windSpeed,
            uvIndex:        uvIndex,
            sunrise:        sunrise,
            sunset:         sunset,
            forecast:       forecastDays,
            hourlyForecast: hourlyForecast,
            cityName:       cityName
        )
    }

    // MARK: - searchCities

    func searchCities(query: String) async throws -> [CitySearchResult] {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://geocoding-api.open-meteo.com/v1/search?name=\(encoded)&count=8&language=en&format=json")
        else { return [] }

        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        let results = json["results"] as? [[String: Any]] ?? []

        return results.compactMap { item in
            guard let id   = item["id"]        as? Int,
                  let name = item["name"]      as? String,
                  let lat  = item["latitude"]  as? Double,
                  let lon  = item["longitude"] as? Double else { return nil }
            return CitySearchResult(
                id: id, name: name,
                country: item["country"] as? String ?? "",
                admin:   item["admin1"]  as? String ?? "",
                latitude: lat, longitude: lon
            )
        }
    }

    // MARK: - Helpers

    private static func formatSunTime(_ isoString: String) -> String {
        guard let date = sunParseFormatter.date(from: isoString) else { return "--" }
        return sunDisplayFormatter.string(from: date)
    }

    private static func mapWeatherCode(_ code: Int) -> WeatherCondition {
        switch code {
        case 0, 1:    return .sunny
        case 2:       return .partlyCloudy
        case 3:       return .cloudy
        case 45, 48:  return .foggy
        case 51...67: return .rainy
        case 71...77: return .snowy
        case 80...82: return .rainy
        case 85, 86:  return .snowy
        case 95...99: return .stormy
        default:      return .partlyCloudy
        }
    }
}
