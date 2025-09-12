struct WeatherManager {
    let weatherUrl = "https://api.openweathermap.org/data/3.0/onecall?exclude=minutely,hourly,daily&appid=0ad817eb245fe651cab840fabf7056f1&units=metric"
    
    
    func fetchWeather(_ cityName: String) {
        let urlString = "\(weatherUrl)&q=\(cityName)"
        
        print(urlString)
    }
}
