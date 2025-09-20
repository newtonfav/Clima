import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherUrl =
        "https://api.openweathermap.org/data/3.0/onecall?exclude=minutely,hourly,daily&appid=0ad817eb245fe651cab840fabf7056f1&units=metric"
    let geocodingUrl =
        "https://api.openweathermap.org/geo/1.0/direct?&appid=0ad817eb245fe651cab840fabf7056f1&limit=1"
    
    var delegate: WeatherManagerDelegate?
    
    
    func fetchCityCordinates(_ cityName: String) {
        let urlString = "\(geocodingUrl)&q=\(cityName)"
        performGeocodingRequest(with: urlString)
    }

    func performGeocodingRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }

                if let safeData = data {
                    let coordinates = parseGeocodingJSON(
                        geocodingData: safeData
                    )

                    fetchWeather(
                        longitude: coordinates?.lat ?? 0.0,
                        latitude: coordinates?.lon ?? 0.0
                    )
                }
            }
            task.resume()
        }
    }

    func parseGeocodingJSON(geocodingData: Data) -> GeocodingData? {
        let decoder = JSONDecoder()

        do {
            let decodedData = try decoder.decode(
                [GeocodingData].self,
                from: geocodingData
            )
            return decodedData[0]
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }

    func fetchWeather(longitude: Double, latitude: Double) {
        let urlString = "\(weatherUrl)&lat=\(latitude)&lon=\(longitude)"
        performWeatherRequest(with: urlString)
    }

    func performWeatherRequest(with urlString: String) {
        // Create URL
        if let url = URL(string: urlString) {
            // Create URLSession
            let session = URLSession(configuration: .default)

            // Give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }

                if let safeData = data {
                    if let weather = parseWeatherJSON(weatherData: safeData) {
                        delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            // Start the task
            task.resume()
        }
    }

    func parseWeatherJSON(weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()

        do {
            let decodedData = try decoder.decode(
                WeatherData.self,
                from: weatherData
            )
        
            let id = decodedData.current.weather[0].id
            let temp = decodedData.current.temp
            let timezone = decodedData.timezone
            let description = decodedData.current.weather[0].description
            
            let weather = WeatherModel(conditionId: id, timezone: timezone, temperature: temp, weatherDescription: description)
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }

    
}
