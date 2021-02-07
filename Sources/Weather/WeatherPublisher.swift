//
// WeatherPublisher.swift
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

import Foundation
import Combine
#if canImport(CoreLocation)
import CoreLocation
#endif

extension Weather {
    public typealias WeatherPublisher = _WeatherPublisher
}

public struct _WeatherPublisher: Publisher {
    public typealias Output = Weather
    public typealias Failure = Error
    
    typealias Upstream = AnyPublisher<(data: Data, response: URLResponse), Error>

    private let latitude: Double
    private let longitude: Double
    
    private var request: URLRequest {
        return URLRequest(
            url: URL(
                string: "https://opendata-download-metfcst.smhi.se/api/category/pmp3g/version/2/geotype/point/lon/\(longitude)/lat/\(latitude)/data.json"
            )!
        )
    }

    init(latitude: Double, longitude: Double) {
        self.latitude = latitude.rounded(toPrecision: 6)
        self.longitude = longitude.rounded(toPrecision: 6)
    }
    
    public func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
        let subscription = WeatherSubscription(subscriber: subscriber)
        subscription.configure(
            request: request
        )
        subscriber.receive(subscription: subscription)
    }
}

// MARK: Subscription
extension _WeatherPublisher {
    fileprivate final class WeatherSubscription<S: Subscriber>: Subscription, Subscriber where S.Input == Output, S.Failure == Failure {
        typealias Input = Upstream.Output
        
        private var upstreamSubscription: Subscription?
        private var downstreamSubscriber: S?
        
        init(subscriber: S) {
            self.downstreamSubscriber = subscriber
        }
        
        func request(_ demand: Subscribers.Demand) {
            guard let upstream = self.upstreamSubscription else { return }
            
            upstream.request(demand)
        }
        
        func cancel() {
            self.downstreamSubscriber = nil
            self.upstreamSubscription = nil
        }
        
        func receive(subscription: Subscription) {
            self.upstreamSubscription = subscription
        }
        
        func receive(_ input: Upstream.Output) -> Subscribers.Demand {
            guard let downstream = self.downstreamSubscriber else { return .none }
            
            do {
                let decoder = JSONDecoder(dateDecodingStrategy: .iso8601)
                let output = try decoder.decode(Output.self, from: input.data)
                return downstream.receive(output)
            } catch {
                downstream.receive(completion: .failure(error))
            }
            
            return .none
        }
        
        func receive(completion: Subscribers.Completion<Upstream.Failure>) {
            self.upstreamSubscription = nil
            
            guard let downstream = self.downstreamSubscriber else {
                return
            }
            downstream.receive(completion: completion)
        }
        
        func configure(request: URLRequest) {
            URLSession.shared.dataTaskPublisher(
                for: request
            )
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
            .subscribe(self)
        }
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
