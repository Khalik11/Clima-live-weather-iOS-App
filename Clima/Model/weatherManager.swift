//
//  weatherManager.swift
//  Clima
//
//  Created by Khalik Kasmani on 18/03/23.
//  Copyright © 2023 Khalik Kasmani. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=50bd816156f7fbb6975898c7763eb975&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityname: String) {
        let urlString = "\(weatherURL)&q=\(cityname)"
        performRequest(urlString: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(urlString: urlString)
    }
    
    func performRequest(urlString: String) {
        
        // 1. Create a URL
        if let url = URL(string: urlString) {
            
            // 2. Create a URLsession
            let session = URLSession(configuration: .default)
            
            // 3. Give the session a task.
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(weatherData: safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            // Start the Task.
            task.resume()
            
        }
    }
    
    func parseJSON(weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, CityName: name, temperature: temp)
            return weather
            
            print(weather.temperatureString)
            
        } catch {
            print(error)
            return nil
        }
    }
    
    
    
}
