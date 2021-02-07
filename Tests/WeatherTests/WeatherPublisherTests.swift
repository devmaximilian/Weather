import Foundation
import Weather
import XCTest
import Combine

class WeatherPublisherTests: XCTestCase {
    let weatherPublisher: Weather.WeatherPublisher = Weather.publisher(latitude: 59.3258414, longitude: 17.7018733)
    var cancellables: [String: AnyCancellable] = [:]
    
    func testWeatherPublisher() {
        let returnWeather = expectation(description: "")
        
        cancellables["request"] = weatherPublisher
            .sink(receiveCompletion: { completion in
                guard case .failure(let error) = completion else {
                    return
                }
                XCTFail(error.localizedDescription)
                returnWeather.fulfill()
            }, receiveValue: { observation in
                returnWeather.fulfill()
            })
        
        wait(for: [returnWeather], timeout: 10)
    }
}
