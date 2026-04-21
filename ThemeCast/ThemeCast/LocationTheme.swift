import SwiftUI
import CoreLocation

// MARK: - Weather Condition
enum WeatherCondition: String {
    case sunny      = "Sunny"
    case cloudy     = "Cloudy"
    case rainy      = "Rainy"
    case snowy      = "Snowy"
    case windy      = "Windy"
    case stormy     = "Stormy"
    case partlyCloudy = "Partly Cloudy"
    case foggy      = "Foggy"
}

// MARK: - Location Theme
struct LocationTheme {
    let regionName: String
    let label: String
    let emoji: String
    let gradientColors: [Color]
    let iconMap: [WeatherCondition: String]
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 34.05, longitude: -118.24)

    func icon(for condition: WeatherCondition) -> String {
        iconMap[condition] ?? "🌡️"
    }
}

// MARK: - Theme Definitions
extension LocationTheme {
    static let losAngeles = LocationTheme(
        regionName: "Los Angeles",
        label: "Beach Vibes",
        emoji: "🌴",
        gradientColors: [
            Color(red: 0.12, green: 0.65, blue: 0.85),
            Color(red: 0.94, green: 0.55, blue: 0.27),
            Color(red: 0.97, green: 0.81, blue: 0.42)
        ],
        iconMap: [
            .sunny: "🌴", .partlyCloudy: "⛱️", .cloudy: "🌊", .rainy: "🌦️",
            .windy: "🏄", .stormy: "⚡", .snowy: "❄️", .foggy: "🌫️"
        ],
        coordinate: CLLocationCoordinate2D(latitude: 34.05, longitude: -118.24)
    )

    static let seattle = LocationTheme(
        regionName: "Seattle",
        label: "Coffee Weather",
        emoji: "☕",
        gradientColors: [
            Color(red: 0.17, green: 0.29, blue: 0.43),
            Color(red: 0.30, green: 0.43, blue: 0.56),
            Color(red: 0.49, green: 0.61, blue: 0.71)
        ],
        iconMap: [
            .sunny: "☀️", .partlyCloudy: "🌤️", .cloudy: "☁️", .rainy: "☔",
            .windy: "🌬️", .stormy: "⛈️", .snowy: "🌨️", .foggy: "☕"
        ],
        coordinate: CLLocationCoordinate2D(latitude: 47.61, longitude: -122.33)
    )

    static let newYork = LocationTheme(
        regionName: "New York",
        label: "City Skyline",
        emoji: "🏙️",
        gradientColors: [
            Color(red: 0.08, green: 0.08, blue: 0.18),
            Color(red: 0.18, green: 0.27, blue: 0.46),
            Color(red: 0.32, green: 0.43, blue: 0.67)
        ],
        iconMap: [
            .sunny: "🌇", .partlyCloudy: "🏙️", .cloudy: "🌆", .rainy: "🌧️",
            .windy: "💨", .stormy: "⛈️", .snowy: "🌨️", .foggy: "🌁"
        ],
        coordinate: CLLocationCoordinate2D(latitude: 40.71, longitude: -74.01)
    )

    static let alaska = LocationTheme(
        regionName: "Alaska",
        label: "Polar Winds",
        emoji: "🐻‍❄️",
        gradientColors: [
            Color(red: 0.04, green: 0.11, blue: 0.21),
            Color(red: 0.09, green: 0.30, blue: 0.43),
            Color(red: 0.29, green: 0.54, blue: 0.67)
        ],
        iconMap: [
            .sunny: "🌅", .partlyCloudy: "🌤️", .cloudy: "☁️", .rainy: "🌧️",
            .windy: "🌬️", .stormy: "🌪️", .snowy: "🐻‍❄️", .foggy: "🌫️"
        ],
        coordinate: CLLocationCoordinate2D(latitude: 64.20, longitude: -152.49)
    )

    static let arizona = LocationTheme(
        regionName: "Arizona",
        label: "Desert Heat",
        emoji: "🌵",
        gradientColors: [
            Color(red: 0.63, green: 0.21, blue: 0.06),
            Color(red: 0.85, green: 0.42, blue: 0.11),
            Color(red: 0.96, green: 0.72, blue: 0.29)
        ],
        iconMap: [
            .sunny: "🌵", .partlyCloudy: "🌤️", .cloudy: "⛅", .rainy: "🌦️",
            .windy: "🏜️", .stormy: "⛈️", .snowy: "❄️", .foggy: "🌫️"
        ],
        coordinate: CLLocationCoordinate2D(latitude: 33.45, longitude: -112.07)
    )

    static let miami = LocationTheme(
        regionName: "Miami",
        label: "Tropical Vibes",
        emoji: "🌺",
        gradientColors: [
            Color(red: 0.00, green: 0.60, blue: 0.70),
            Color(red: 0.94, green: 0.35, blue: 0.55),
            Color(red: 0.99, green: 0.75, blue: 0.30)
        ],
        iconMap: [
            .sunny: "🌺", .partlyCloudy: "🌴", .cloudy: "🌊", .rainy: "🌧️",
            .windy: "🏖️", .stormy: "🌀", .snowy: "❄️", .foggy: "🌫️"
        ],
        coordinate: CLLocationCoordinate2D(latitude: 25.76, longitude: -80.19)
    )

    static let chicago = LocationTheme(
        regionName: "Chicago",
        label: "Windy City",
        emoji: "🌬️",
        gradientColors: [
            Color(red: 0.10, green: 0.15, blue: 0.30),
            Color(red: 0.20, green: 0.35, blue: 0.55),
            Color(red: 0.40, green: 0.55, blue: 0.75)
        ],
        iconMap: [
            .sunny: "🏛️", .partlyCloudy: "🌤️", .cloudy: "☁️", .rainy: "🌂",
            .windy: "🌬️", .stormy: "⛈️", .snowy: "🌨️", .foggy: "🌁"
        ],
        coordinate: CLLocationCoordinate2D(latitude: 41.88, longitude: -87.63)
    )

    /// Detect a theme from a CLPlacemark
    static func theme(for placemark: CLPlacemark) -> LocationTheme {
        let state = placemark.administrativeArea ?? ""
        let city  = placemark.locality ?? ""
        let combined = "\(city) \(state)".lowercased()

        switch true {
        case combined.contains("los angeles") || combined.contains("santa monica") || combined.contains("malibu"):
            return .losAngeles
        case combined.contains("seattle") || combined.contains("tacoma") || combined.contains("olympia"):
            return .seattle
        case combined.contains("new york") || combined.contains("brooklyn") || combined.contains("manhattan"):
            return .newYork
        case state == "AK":
            return .alaska
        case state == "AZ":
            return .arizona
        case combined.contains("miami") || combined.contains("miami beach") || combined.contains("coral gables"):
            return .miami
        case combined.contains("chicago") || combined.contains("evanston"):
            return .chicago
        default:
            return theme(forLatitude: placemark.location?.coordinate.latitude ?? 40)
        }
    }

    /// Pick a theme based on latitude (for searched cities)
    static func theme(forLatitude lat: Double) -> LocationTheme {
        if lat > 60 { return .alaska }
        if lat > 45 { return .seattle }
        if lat > 38 { return .chicago }
        if lat < 28 { return .miami }
        if lat < 33 { return .arizona }
        return .newYork
    }

    static let all: [LocationTheme] = [.losAngeles, .seattle, .newYork, .alaska, .arizona, .miami, .chicago]
}
