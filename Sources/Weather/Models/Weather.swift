//
// Observation.swift
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


/// An `Observation` is a collection of `Forecast` instances
public struct Weather: Decodable {
    /// A timestamp for when the `Forecast` was approved
    public let approvedTime: Date

    /// A timestamp for when the `Forecast` was created or updated
    public let referenceTime: Date

    /// A `Geometry` represenation for where the `Forecast` is valid
    public let geometry: Geometry

    /// An array of `Forecast` instances that reflect the overall `Forecast` over time
    private let timeSeries: [Forecast]
}

/// An extension to house convenience attributes
extension Weather {
    /// - Returns: Whether or not any relevant forecasts are available
    public var isRelevant: Bool {
        return forecasts.count > 0
    }
    
    public var forecast: Forecast? {
        return get()
    }
    
    public var unsafeForecast: Forecast {
        return forecast.unsafelyUnwrapped
    }
    
    public var forecasts: [Forecast] {
        let now: Date = .oneHourAgo
        return timeSeries.sorted(by: { $0.validTime < $1.validTime })
            .filter { forecast -> Bool in
                forecast.validTime >= now
            }
    }
    
    /// - Returns: The most relevant `Forecast`
    public func get(by date: Date? = nil) -> Forecast? {
        let date: Date = date ?? .oneHourAgo
        return forecasts.first { forecast -> Bool in
                forecast.validTime >= date
            }
    }
}

extension Date {
    fileprivate static var oneHourAgo: Date {
        return Date(timeIntervalSinceNow: 60 * 60 * -1)
    }
}

extension Weather {
    public static func publisher(latitude: Double, longitude: Double) -> WeatherPublisher {
        return WeatherPublisher(
            latitude: latitude,
            longitude: longitude
        )
    }
}
