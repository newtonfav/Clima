struct WeatherModel {
    let cityName: String
    let stateName: String
    let countryName: String
    let conditionId: Int
    let timezone: String
    let temperature: Double
    let weatherDescription: String
    
    init(weatherData: WeatherData, cityData: ReverseGeocodingData ) {
        self.cityName = cityData.name
        self.stateName = cityData.state
        self.countryName = cityData.country
        self.conditionId = weatherData.current.weather[0].id
        self.timezone = weatherData.timezone
        self.temperature = weatherData.current.temp
        self.weatherDescription = weatherData.current.weather[0].description
    }
    
    var temperatureString: String {
        return String(format: "%.1f", temperature)
    }
    
    var conditionName: String {
        switch conditionId {
        case 200...232:
            return "cloud.bolt"
        case 300...321:
            return "cloud.drizzle"
        case 500...531:
            return "cloud.rain"
        case 600...622:
            return "cloud.snow"
        case 701...781:
            return "cloud.fog"
        case 800:
            return "sun.max"
        case 801...804:
            return "cloud.bolt"
        default:
            return "cloud"
        }
    }
}
