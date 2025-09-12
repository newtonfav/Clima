import Foundation

struct WeatherManager {
    let weatherUrl =
        "https://api.openweathermap.org/data/3.0/onecall?exclude=minutely,hourly,daily&appid=0ad817eb245fe651cab840fabf7056f1&units=metric"
    let geocodingUrl = "http://api.openweathermap.org/geo/1.0/direct?limit=1"
    
    var longitude = 7.4892974
    var latitude = 9.0643305

    func fetchCityCordinates(_ cityName: String) {
        let urlString = "\(geocodingUrl)&q=\(cityName)"

        print(urlString)
    }

    func performGeocodingRequest(urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                
            }
            task.resume()
        }
    }

    func fetchWeather(_ cityName: String) {
        let urlString = "\(weatherUrl)&lat=\(latitude)&lon=\(longitude)"

        performWeatherRequest(urlString: urlString)
    }

    func performWeatherRequest(urlString: String) {
        // Create URL
        if let url = URL(string: urlString) {
            // Create URLSession
            let session = URLSession(configuration: .default)

            // Give the session a task
            let task = session.dataTask(with: url, completionHandler: handle)

            // Start the task
            task.resume()
        }
    }

    func handle(data: Data?, response: URLResponse?, error: Error?) {
        if error != nil {
            print(error!)
            return
        }

        if let safeData = data {
            let dataString = String(data: safeData, encoding: .utf8)
            print(dataString ?? "No data")
        }
    }
}
