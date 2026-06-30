import SwiftUI

// MARK: - App entry point

@main
struct WeatherApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - Model

struct Weather: Identifiable {
    let id = UUID()
    let city: String
    let temperature: Double
    let condition: String
    let symbol: String   // SF Symbol name
}

// MARK: - Service
// A mock service so the app builds and runs with NO API key.
// To use real data later, make a type that conforms to WeatherProviding
// and calls the OpenWeatherMap API, then swap it in ContentView.

protocol WeatherProviding {
    func currentWeather(for city: String) async throws -> Weather
}

struct MockWeatherService: WeatherProviding {
    func currentWeather(for city: String) async throws -> Weather {
        try await Task.sleep(nanoseconds: 300_000_000) // pretend to call the network
        let samples = [
            Weather(city: city, temperature: 24, condition: "Sunny",  symbol: "sun.max.fill"),
            Weather(city: city, temperature: 18, condition: "Cloudy", symbol: "cloud.fill"),
            Weather(city: city, temperature: 15, condition: "Rain",   symbol: "cloud.rain.fill"),
            Weather(city: city, temperature: 27, condition: "Clear",  symbol: "sun.max.fill")
        ]
        return samples.randomElement()!
    }
}

// MARK: - View

struct ContentView: View {
    @State private var city = "Nairobi"
    @State private var weather: Weather?
    @State private var isLoading = false

    private let service: WeatherProviding = MockWeatherService()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                TextField("Enter a city", text: $city)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                if isLoading {
                    ProgressView()
                        .padding(.top, 40)
                } else if let weather {
                    VStack(spacing: 8) {
                        Image(systemName: weather.symbol)
                            .font(.system(size: 72))
                            .symbolRenderingMode(.multicolor)
                        Text("\(Int(weather.temperature))°C")
                            .font(.system(size: 52, weight: .bold))
                        Text(weather.condition)
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        Text(weather.city)
                            .font(.headline)
                    }
                    .padding(.top, 24)
                } else {
                    Text("Tap below to load the weather")
                        .foregroundStyle(.secondary)
                        .padding(.top, 40)
                }

                Button("Get Weather") {
                    Task { await load() }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Spacer()
            }
            .padding(.top, 40)
            .navigationTitle("Weather")
        }
    }

    private func load() async {
        isLoading = true
        defer { isLoading = false }
        weather = try? await service.currentWeather(for: city)
    }
}

#Preview {
    ContentView()
}
