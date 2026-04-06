# ThemeCast – iOS Weather App

A SwiftUI weather app that swaps its icons and colour theme based on your location.

## File Structure

```
ThemeCast/
├── ThemeCastApp.swift      — @main entry point
├── ContentView.swift       — root view
├── WeatherView.swift       — main screen (gradient bg, big icon, forecast, city picker)
├── SubViews.swift          — ForecastDayView, WeatherStatView, NavButton, FloatingModifier
├── WeatherViewModel.swift  — @MainActor ObservableObject wiring location ↔ weather
├── LocationTheme.swift     — theme definitions + CLPlacemark → theme detection
├── WeatherService.swift    — WeatherData model + MockWeatherService (+ WeatherKit stub)
├── LocationManager.swift   — CLLocationManager wrapper (async/await + Combine)
└── Info.plist              — NSLocationWhenInUseUsageDescription + scene config
```

## Getting Started

### 1. Create a new Xcode project

- File → New → Project → iOS → App
- Product Name: `ThemeCast`
- Interface: **SwiftUI**
- Language: **Swift**
- Minimum Deployment: **iOS 16.0+**

### 2. Add the source files

Drag all `.swift` files and `Info.plist` into the project navigator.  
Delete Xcode's auto-generated `ContentView.swift` first, then add the one from this package.

### 3. Set the Info.plist

In **Build Settings → Info.plist File**, make sure it points to `ThemeCast/Info.plist`
(or merge the `NSLocationWhenInUseUsageDescription` key into your existing plist).

### 4. Run on device or simulator

The app ships with `MockWeatherService` — no API key needed.  
Tap any city in the bottom pill-picker to switch themes and see the gradient + icon change live.

---

## Switching to Live Weather (WeatherKit)

1. In **Signing & Capabilities**, add the **WeatherKit** capability.
2. Enable WeatherKit in your App ID on the Apple Developer portal.
3. In `WeatherService.swift`, uncomment the `WeatherKitService` class and fill in `mapCondition(_:)`.
4. In `WeatherViewModel.swift`, replace `MockWeatherService()` with `WeatherKitService()`.

---

## Adding More Location Themes

Open `LocationTheme.swift` and:

1. Add a new `static let` theme inside the `LocationTheme` extension.
2. Add a matching `case` inside `theme(for placemark:)`.
3. Append the theme to the `all` array.

```swift
static let miami = LocationTheme(
    regionName: "Miami",
    label: "Neon Tropics",
    emoji: "🦩",
    gradientColors: [
        Color(red: 0.95, green: 0.25, blue: 0.55),
        Color(red: 0.99, green: 0.65, blue: 0.20)
    ],
    iconMap: [
        .sunny: "🦩",
        .rainy: "🌧️",
        // …
    ]
)
```

---

## Architecture

```
WeatherView  ←  WeatherViewModel  ←  LocationManager (CLLocation)
                                  ←  WeatherService  (API / mock)
                                  ←  LocationTheme   (pure data)
```

`WeatherViewModel` is a `@MainActor` `ObservableObject`.  
`LocationManager` publishes `CLPlacemark` changes via Combine; the VM picks those up and fires a weather fetch.  
`LocationTheme` is pure value-type data — no side effects, easy to extend and test.

---

## Requirements

- Xcode 15+
- iOS 16.0+
- Swift 5.9+
- No third-party dependencies
