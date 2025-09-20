struct WeatherData: Decodable {
    let timezone: String
    let current: CurrentWeatherData
}

struct CurrentWeatherData: Decodable {
    let temp: Double
    let feels_like: Double
    let weather: [WeatherInfo]
}

struct WeatherInfo: Decodable {
    let id: Int
    let main: String
    let description: String
}

struct GeocodingData: Decodable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String
    let state: String
}

struct ReverseGeocodingData: Decodable {
    let name: String
    let state: String
    let country: String
}
