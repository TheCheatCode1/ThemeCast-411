import SwiftUI

// MARK: - Forecast Day Cell

struct ForecastDayView: View {
    let day: DayForecast
    let icon: String
    var isCelsius: Bool = false

    private func temp(_ f: Int) -> String {
        isCelsius ? "\((f - 32) * 5 / 9)°" : "\(f)°"
    }

    var body: some View {
        VStack(spacing: 5) {
            Text(day.dayName)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
                .tracking(0.5)

            Text(icon)
                .font(.system(size: 22))

            Text(temp(day.high))
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)

            Text(temp(day.low))
                .font(.system(size: 11, weight: .light))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Weather Stat Badge

struct WeatherStatView: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)

            Text(label)
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(.white.opacity(0.5))
                .tracking(0.3)
        }
    }
}

// MARK: - Bottom Nav Button (updated with optional action)

struct NavButton: View {
    let icon: String
    let label: String
    let isActive: Bool
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            action?()
        } label: {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .tracking(0.3)
            }
            .foregroundColor(isActive ? .white : .white.opacity(0.4))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Floating animation modifier

struct FloatingModifier: ViewModifier {
    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 3.5)
                    .repeatForever(autoreverses: true)
                ) {
                    offset = -10
                }
            }
    }
}

extension View {
    func floatingAnimation() -> some View {
        modifier(FloatingModifier())
    }
}

// MARK: - Error Banner

struct ErrorBanner: View {
    let message: String
    let dismiss: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(message)
                .font(.system(size: 13))
                .lineLimit(2)
            Spacer()
            Button(action: dismiss) {
                Image(systemName: "xmark.circle.fill")
            }
        }
        .foregroundColor(.white)
        .padding(12)
        .background(.red.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }
}

// MARK: - Previews

#Preview("ForecastDay") {
    ForecastDayView(
        day: DayForecast(dayName: "Mon", condition: .sunny, high: 78, low: 62),
        icon: "🌴"
    )
    .padding()
    .background(Color.blue)
}

#Preview("WeatherStat") {
    WeatherStatView(icon: "humidity.fill", value: "42%", label: "Humidity")
        .padding()
        .background(Color.indigo)
}
