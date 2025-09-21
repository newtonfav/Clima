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
    let reverseGeocodingUrl = "https://api.openweathermap.org/geo/1.0/reverse?appid=0ad817eb245fe651cab840fabf7056f1&limit=1"
    var delegate: WeatherManagerDelegate?
}



//MARK: - FetchCityCoordinates
extension WeatherManager {
    func fetchCityCordinates(_ cityName: String) async throws {
        let urlString = "\(geocodingUrl)&q=\(cityName)"
        try await performGeocodingRequest(with: urlString)
    }

    func performGeocodingRequest(with urlString: String) async throws  {
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        let geocodingData = try decoder.decode([GeocodingData].self, from: data)
        let coordinates = geocodingData[0]
        
        fetchWeather(longitude: coordinates.lon, latitude: coordinates.lat)
    }
}

//MARK: - FetchCityData
extension WeatherManager {
    func fetchCityData(latitude: Double, longitude: Double) async throws -> ReverseGeocodingData {
        let urlString = "\(reverseGeocodingUrl)&lat=\(latitude)&lon=\(longitude)"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        let decodedData = try decoder.decode([ReverseGeocodingData].self, from: data)
        return decodedData[0]
    }
}

//MARK: - FetchWeather
extension WeatherManager {
    func fetchWeather(longitude: Double, latitude: Double) {
        let urlString = "\(weatherUrl)&lat=\(latitude)&lon=\(longitude)"
        
        Task {
            do {
                let cityData = try await fetchCityData(latitude: latitude, longitude: longitude)
                performWeatherRequest(with: urlString, data: cityData)
            } catch {
                self.delegate?.didFailWithError(error: error)
            }
        }
    }
    

    func performWeatherRequest(with urlString: String, data cityData: ReverseGeocodingData) {
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
                    if let weatherData = parseWeatherJSON(weatherData: safeData) {
                        let weather = WeatherModel(weatherData: weatherData, cityData: cityData)
                        delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            // Start the task
            task.resume()
        }
    }

    func parseWeatherJSON(weatherData: Data) -> WeatherData? {
        let decoder = JSONDecoder()

        do {
            let decodedWeatherData = try decoder.decode(
                WeatherData.self,
                from: weatherData
            )
            return decodedWeatherData
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
