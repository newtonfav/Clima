import Foundation

struct WeatherManager {
    let weatherUrl =
        "https://api.openweathermap.org/data/3.0/onecall?exclude=minutely,hourly,daily&appid=0ad817eb245fe651cab840fabf7056f1&units=metric"
    let geocodingUrl =
        "https://api.openweathermap.org/geo/1.0/direct?&appid=0ad817eb245fe651cab840fabf7056f1&limit=1"

    func fetchCityCordinates(_ cityName: String) {
        let urlString = "\(geocodingUrl)&q=\(cityName)"
        performGeocodingRequest(urlString: urlString)
    }

    func performGeocodingRequest(urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!)
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
            print(error)
            return nil
        }
    }

    func fetchWeather(longitude: Double, latitude: Double) {
        let urlString = "\(weatherUrl)&lat=\(latitude)&lon=\(longitude)"
        performWeatherRequest(urlString: urlString)
    }

    func performWeatherRequest(urlString: String) {
        // Create URL
        if let url = URL(string: urlString) {
            // Create URLSession
            let session = URLSession(configuration: .default)

            // Give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }

                if let safeData = data {
                    parseJSON(weatherData: safeData)
                }
            }
            // Start the task
            task.resume()
        }
    }

    func parseJSON(weatherData: Data) {
        let decoder = JSONDecoder()

        do {
            let decodedData = try decoder.decode(
                WeatherData.self,
                from: weatherData
            )
            print(decodedData.current.weather[0].description)
            let weatherId = decodedData.current.weather[0].id
            let conditionName = getWeatherConditionName(weatherId)
            print(weatherId)
            print(conditionName)
        } catch {
            print(error)
        }
    }

    func getWeatherConditionName(_ weatherId: Int) -> String {
        switch weatherId {
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
