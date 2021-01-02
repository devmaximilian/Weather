import Foundation
import MetobsKit
import XCTest
import Combine

class ForecastPublisherTests: XCTestCase {
    let forecastPublisher: ForecastPublisher = ForecastPublisher(latitude: 59.3258414, longitude: 17.7018733)
    var cancellables: [String: AnyCancellable] = [:]
    
    func testForecastPublisher() {
        let returnForecastObservation = expectation(description: "")
        
        cancellables["request"] = forecastPublisher
            .sink(receiveCompletion: { completion in
                guard case .failure(let error) = completion else {
                    return
                }
                XCTFail(error.localizedDescription)
                returnForecastObservation.fulfill()
            }, receiveValue: { observation in
                returnForecastObservation.fulfill()
            })
        
        wait(for: [returnForecastObservation], timeout: 10)
    }
    
}
