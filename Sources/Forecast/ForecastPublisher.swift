//
// ForecastPublisher.swift
//
// Copyright (c) 2019 Maximilian Wendel
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the  Software), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED  AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import class Foundation.HTTPURLResponse
import class Foundation.URLResponse
import class Foundation.JSONDecoder
import class Foundation.URLSession
import struct Foundation.URLError
import struct Foundation.Data
import struct Foundation.URL
import func Foundation.pow
import protocol Combine.Publisher
import protocol Combine.Subscriber
import class Combine.PassthroughSubject
import class Combine.AnyCancellable
import struct Combine.AnyPublisher
import enum Combine.Subscribers
#if canImport(CoreLocation)
import struct CoreLocation.CLLocationCoordinate2D
import class CoreLocation.CLLocation
#endif


/// The service endpoint to send requests to
@inline(__always)
fileprivate let endpoint: String = "https://opendata-download-metfcst.smhi.se/api/category/pmp3g/version/2/geotype/point/lon/{LONGITUDE}/lat/{LATITUDE}/data.json"

/// A service that provides weather forecasts
public class ForecastPublisher: Publisher {
    public typealias Output = Observation
    public typealias Failure = Error
    
    private let subject: PassthroughSubject<Output, Failure> = .init()
    private var cancellables: [String: AnyCancellable] = [:]
    private let latitude: Double
    private let longitude: Double
    private var configured: Bool = false
    
    /// Get the weather forecast `Observation` for a specific set of coordinates
    /// - Note: See https://www.smhi.se/data/utforskaren-oppna-data/meteorologisk-prognosmodell-pmp3g-2-8-km-upplosning-api
    ///         for information about limitations (such as coordinate limitations)
    /// - Parameters:
    ///   - latitude: The coordinate latitude
    ///   - longitude: The coordinate longitude
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    #if canImport(CoreLocation)
    /// Get the weather forecast `Observation` for a specific set of coordinates
    /// - Note: See https://www.smhi.se/data/utforskaren-oppna-data/meteorologisk-prognosmodell-pmp3g-2-8-km-upplosning-api
    ///         for information about limitations (such as coordinate limitations)
    /// - Parameters:
    ///   - coordinate: An instance of `CLLocationCoordinate2D`
    public convenience init(coordinate: CLLocationCoordinate2D) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    /// Get the weather forecast `Observation` for a specific set of coordinates
    /// - Note: See https://www.smhi.se/data/utforskaren-oppna-data/meteorologisk-prognosmodell-pmp3g-2-8-km-upplosning-api
    ///         for information about limitations (such as coordinate limitations)
    /// - Parameters:
    ///   - location: An instance of `CLLocation`
    public convenience init(location: CLLocation) {
        self.init(coordinate: location.coordinate)
    }
    #endif
    
    /// Attaches the specified subscriber to this publisher.
    ///
    /// Implementations of ``Publisher`` must implement this method.
    ///
    /// The provided implementation of ``Publisher/subscribe(_:)``calls this method.
    ///
    /// - Parameter subscriber: The subscriber to attach to this ``Publisher``, after which it can receive values.
    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        self.subject.receive(subscriber: subscriber)
        
        guard self.configured == false else {
            return
        }
        
        self.configured = true
        self.configure()
    }
}

// MARK: - Private methods

extension ForecastPublisher {
    // Called upon first subscription
    private func configure() {
        let url = self.makeURL(latitude: latitude, longitude: longitude)
        
        self.cancellables["request"] = self.request(url)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self, case .failure = completion else { return }
                
                self.subject.send(completion: completion)
            }, receiveValue: { [weak self] input in
                guard let self = self else { return }
                
                self.subject.send(input)
            })
    }
    
    private func request(_ url: URL) -> AnyPublisher<Output, Error> {
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { (data: Data, response: URLResponse) -> (data: Data, response: HTTPURLResponse) in
                guard let response = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                // Check status code
                guard 200...299 ~= response.statusCode else {
                    throw URLError(.init(rawValue: response.statusCode))
                }
                return (data, response)
            }
            .map { (data: Data, response: URLResponse) -> Data in
                return data
            }
            .decode(type: Output.self, decoder: JSONDecoder(dateDecodingStrategy: .iso8601))
            .eraseToAnyPublisher()
    }
    
    private func makeURL(latitude: Double, longitude: Double) -> URL {
        // Remove decimals exceeding six positions as it will cause a 404 response
        let latitude = latitude.rounded(toPrecision: 6)
        let longitude = longitude.rounded(toPrecision: 6)

        let stringURL = endpoint
            .replacingOccurrences(
                of: "{LONGITUDE}",
                with: longitude.description
            )
            .replacingOccurrences(
                of: "{LATITUDE}",
                with: latitude.description
            )
        
        return URL(string: stringURL)
            .unsafelyUnwrapped
    }
}

// MARK: Extensions

extension JSONDecoder {
    fileprivate convenience init(dateDecodingStrategy: JSONDecoder.DateDecodingStrategy) {
        self.init()
        
        self.dateDecodingStrategy = dateDecodingStrategy
    }
}

/// An extension to add the rounded method
extension Double {
    /// Rounds the `Double` to a specified precision-level (number of decimals)
    /// - Note: This method is present as the forecast service only accepts a maximum of six decimals
    /// - Parameter precision: The precision-level to use
    fileprivate func rounded(toPrecision precision: Int) -> Double {
        let multiplier: Double = pow(10, Double(precision))
        return (self * multiplier).rounded() / multiplier
    }
}
