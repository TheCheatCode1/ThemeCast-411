import SwiftUI
import CoreLocation

// MARK: - Weather Condition
enum WeatherCondition: String {
    case sunny        = "Sunny"
    case cloudy       = "Cloudy"
    case rainy        = "Rainy"
    case snowy        = "Snowy"
    case windy        = "Windy"
    case stormy       = "Stormy"
    case partlyCloudy = "Partly Cloudy"
    case foggy        = "Foggy"
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

    // MARK: United States — West

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

    static let lasVegas = LocationTheme(
        regionName: "Las Vegas",
        label: "Neon Nights",
        emoji: "🎰",
        gradientColors: [
            Color(red: 0.08, green: 0.04, blue: 0.18),
            Color(red: 0.35, green: 0.08, blue: 0.52),
            Color(red: 0.85, green: 0.15, blue: 0.65)
        ],
        iconMap: [
            .sunny: "🎰", .partlyCloudy: "✨", .cloudy: "🌑", .rainy: "🌧️",
            .windy: "💨", .stormy: "⛈️", .snowy: "❄️", .foggy: "🌫️"
        ],
        coordinate: CLLocationCoordinate2D(latitude: 36.17, longitude: -115.14)
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

    // MARK: United States — South & Tropics

    static let hawaii = LocationTheme(
        regionName: "Hawaii",
        label: "Aloha State",
        emoji: "🏝️",
        gradientColors: [
            Color(red: 0.00, green: 0.42, blue: 0.70),
            Color(red: 0.95, green: 0.45, blue: 0.20),
            Color(red: 0.98, green: 0.78, blue: 0.35)
        ],
        iconMap: [
            .sunny: "🌺", .partlyCloudy: "🌤️", .cloudy: "🌊", .rainy: "🌦️",
            .windy: "🏄", .stormy: "🌀", .snowy: "❄️", .foggy: "🌫️"
        ],
        coordinate: CLLocationCoordinate2D(latitude: 21.31, longitude: -157.86)
    )

    static let newOrleans = LocationTheme(
        regionName: "New Orleans",
        label: "Jazz & Soul",
        emoji: "🎷",
        gradientColors: [
            Color(red: 0.18, green: 0.08, blue: 0.32),
            Color(red: 0.52, green: 0.22, blue: 0.12),
            Color(red: 0.88, green: 0.68, blue: 0.12)
        ],
        iconMap: [
            .sunny: "🎷", .partlyCloudy: "🌤️", .cloudy: "☁️", .rainy: "🌧️",
            .windy: "🎺", .stormy: "⛈️", .snowy: "❄️", .foggy: "🌫️"
        ],
        coordinate: CLLocationCoordinate2D(latitude: 29.95, longitude: -90.07)
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

    // MARK: United States — East & Central

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

    // MARK: Europe

    static let london = LocationTheme(
        regionName: "London",
        label: "Foggy City",
        emoji: "🎡",
        gradientColors: [
            Color(red: 0.22, green: 0.25, blue: 0.30),
            Color(red: 0.38, green: 0.42, blue: 0.48),
            Color(red: 0.55, green: 0.60, blue: 0.58)
        ],
        iconMap: [
            .sunny: "☀️", .partlyCloudy: "🌤️", .cloudy: "☁️", .rainy: "☔",
            .windy: "🌂", .stormy: "⛈️", .snowy: "❄️", .foggy: "🎡"
        ],
        coordinate: CLLocationCoordinate2D(latitude: 51.51, longitude: -0.13)
    )

    static let paris = LocationTheme(
        regionName: "Paris",
        label: "City of Light",
        emoji: "🗼",
        gradientColors: [
            Color(red: 0.42, green: 0.35, blue: 0.52),
            Color(red: 0.72, green: 0.55, blue: 0.30),
            Color(red: 0.92, green: 0.82, blue: 0.58)
        ],
        iconMap: [
            .sunny: "🗼", .partlyCloudy: "🌤️", .cloudy: "☁️", .rainy: "🌧️",
            .windy: "💨", .stormy: "⛈️", .snowy: "❄️", .foggy: "🌫️"
        ],
        coordinate: CLLocationCoordinate2D(latitude: 48.85, longitude: 2.35)
    )

    // MARK: Middle East

    static let dubai = LocationTheme(
        regionName: "Dubai",
        label: "Golden Sands",
        emoji: "🌙",
        gradientColors: [
            Color(red: 0.12, green: 0.08, blue: 0.05),
            Color(red: 0.52, green: 0.36, blue: 0.10),
            Color(red: 0.88, green: 0.70, blue: 0.25)
        ],
        iconMap: [
            .sunny: "✨", .partlyCloudy: "🌤️", .cloudy: "⛅", .rainy: "🌦️",
            .windy: "🌪️", .stormy: "⛈️", .snowy: "❄️", .foggy: "🌫️"
        ],
        coordinate: CLLocationCoordinate2D(latitude: 25.20, longitude: 55.27)
    )

    // MARK: Asia

    static let tokyo = LocationTheme(
        regionName: "Tokyo",
        label: "Neon Sakura",
        emoji: "🌸",
        gradientColors: [
            Color(red: 0.18, green: 0.10, blue: 0.28),
            Color(red: 0.65, green: 0.20, blue: 0.45),
            Color(red: 0.95, green: 0.75, blue: 0.85)
        ],
        iconMap: [
            .sunny: "🌸", .partlyCloudy: "🌤️", .cloudy: "☁️", .rainy: "☂️",
            .windy: "🎐", .stormy: "⛈️", .snowy: "⛩️", .foggy: "🌫️"
        ],
        coordinate: CLLocationCoordinate2D(latitude: 35.68, longitude: 139.69)
    )

    // MARK: Oceania

    static let sydney = LocationTheme(
        regionName: "Sydney",
        label: "Harbour City",
        emoji: "🦘",
        gradientColors: [
            Color(red: 0.05, green: 0.45, blue: 0.75),
            Color(red: 0.20, green: 0.65, blue: 0.88),
            Color(red: 0.65, green: 0.90, blue: 0.95)
        ],
        iconMap: [
            .sunny: "⛵", .partlyCloudy: "🌤️", .cloudy: "☁️", .rainy: "🌧️",
            .windy: "🏄", .stormy: "⛈️", .snowy: "❄️", .foggy: "🌫️"
        ],
        coordinate: CLLocationCoordinate2D(latitude: -33.87, longitude: 151.21)
    )

    // MARK: South America

    static let rio = LocationTheme(
        regionName: "Rio de Janeiro",
        label: "Carnival City",
        emoji: "🎭",
        gradientColors: [
            Color(red: 0.05, green: 0.40, blue: 0.20),
            Color(red: 0.90, green: 0.72, blue: 0.05),
            Color(red: 0.90, green: 0.35, blue: 0.12)
        ],
        iconMap: [
            .sunny: "🎭", .partlyCloudy: "🌤️", .cloudy: "⛅", .rainy: "🌧️",
            .windy: "🌊", .stormy: "🌩️", .snowy: "❄️", .foggy: "🌫️"
        ],
        coordinate: CLLocationCoordinate2D(latitude: -22.91, longitude: -43.17)
    )

    // MARK: - Theme Detection

    /// Detect a theme from a GPS placemark (uses city name + country code for accuracy)
    static func theme(for placemark: CLPlacemark) -> LocationTheme {
        let state       = placemark.administrativeArea ?? ""
        let city        = placemark.locality ?? ""
        let countryCode = placemark.isoCountryCode ?? ""
        let combined    = "\(city) \(state)".lowercased()

        switch true {
        // International — country code prevents false matches (e.g. Paris, Texas)
        case combined.contains("london")         && countryCode == "GB": return .london
        case combined.contains("paris")          && countryCode == "FR": return .paris
        case combined.contains("tokyo")          && countryCode == "JP": return .tokyo
        case combined.contains("dubai")          && countryCode == "AE": return .dubai
        case combined.contains("sydney")         && countryCode == "AU": return .sydney
        case combined.contains("rio de janeiro") && countryCode == "BR": return .rio

        // United States
        case combined.contains("los angeles") || combined.contains("santa monica") || combined.contains("malibu"):
            return .losAngeles
        case combined.contains("las vegas"):
            return .lasVegas
        case state == "HI" || combined.contains("honolulu"):
            return .hawaii
        case combined.contains("new orleans"):
            return .newOrleans
        case combined.contains("miami") || combined.contains("miami beach") || combined.contains("coral gables"):
            return .miami
        case combined.contains("new york") || combined.contains("brooklyn") || combined.contains("manhattan"):
            return .newYork
        case combined.contains("chicago") || combined.contains("evanston"):
            return .chicago
        case combined.contains("seattle") || combined.contains("tacoma") || combined.contains("olympia"):
            return .seattle
        case state == "AK": return .alaska
        case state == "AZ": return .arizona

        default:
            return theme(forLatitude: placemark.location?.coordinate.latitude ?? 40)
        }
    }

    /// Detect a theme for a searched city using name + country + latitude fallback
    static func theme(for city: CitySearchResult) -> LocationTheme {
        let name    = city.name.lowercased()
        let country = city.country.lowercased()
        let admin   = city.admin.lowercased()

        // International — pair city name with country to avoid collisions
        if name.contains("london")          && country.contains("united kingdom") { return .london }
        if name.contains("paris")           && country.contains("france")         { return .paris }
        if name.contains("tokyo")           && country.contains("japan")          { return .tokyo }
        if name.contains("dubai")           && country.contains("emirates")       { return .dubai }
        if name.contains("sydney")          && country.contains("australia")      { return .sydney }
        if name.contains("rio de janeiro")  && country.contains("brazil")         { return .rio }

        // US cities — name alone is specific enough for these
        if name.contains("los angeles") || name.contains("santa monica") || name.contains("malibu") { return .losAngeles }
        if name.contains("las vegas")                                                                { return .lasVegas }
        if name.contains("honolulu") || admin.contains("hawaii")                                    { return .hawaii }
        if name.contains("new orleans")                                                              { return .newOrleans }
        if name.contains("miami")                                                                    { return .miami }
        if name.contains("new york") || name.contains("manhattan") || name.contains("brooklyn")     { return .newYork }
        if name.contains("chicago")                                                                  { return .chicago }
        if name.contains("seattle") || name.contains("tacoma")                                      { return .seattle }
        if admin.contains("alaska")                                                                  { return .alaska }
        if admin.contains("arizona")                                                                 { return .arizona }

        return theme(forLatitude: city.latitude)
    }

    /// Latitude-band fallback — now handles southern hemisphere correctly
    static func theme(forLatitude lat: Double) -> LocationTheme {
        if lat > 60  { return .alaska }   // arctic/subarctic
        if lat > 45  { return .seattle }  // northern temperate
        if lat > 38  { return .chicago }  // mid-latitude
        if lat > 23  { return .newYork }  // warm temperate
        if lat > -23 { return .miami }    // tropics
        if lat > -40 { return .sydney }   // southern temperate
        return .alaska                    // sub-antarctic
    }

    // All themes for the city picker (grouped by region)
    static let all: [LocationTheme] = [
        .losAngeles, .lasVegas, .hawaii, .newOrleans, .miami,
        .newYork, .chicago, .seattle, .alaska, .arizona,
        .london, .paris, .dubai, .tokyo, .sydney, .rio
    ]
}
