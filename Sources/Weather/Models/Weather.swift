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
    /// - Returns: Whether or not the forecast is valid for the current date
    public var isRelevant: Bool {
        let now = Date()
        return self.timeSeries.contains { forecast -> Bool in
            forecast.validTime > now
        }
    }
    
    /// - Returns: The current `Forecast`
    public func get(by date: Date = .init()) -> Forecast? {
        return self.timeSeries.sorted(by: { $0.validTime < $1.validTime })
            .first { forecast -> Bool in
                forecast.validTime >= date
            }
    }
}

// MARK: Convenience

extension Array {
    func first<Value>(where keyPath: KeyPath<Element, Value>, _ value: Value) -> Element? where Value: Equatable {
        self.first { element in
            element[keyPath: keyPath] == value
        }
    }
}

extension Parameter {
    fileprivate var value: Double {
        return values.first ?? 0
    }
}

extension Forecast {
    fileprivate func parameter<T>(byName name: Parameter.Name, transform: (Parameter) -> T) -> T {
        return transform(parameters.first(where: \.name, name).unsafelyUnwrapped)
    }
}

extension Weather {
    fileprivate var forecast: Forecast {
        return self.get() ?? Forecast(validTime: .distantPast, parameters: [])
    }
    
    fileprivate var forecasts: [Forecast] {
        return self.timeSeries.sorted(by: { $0.validTime < $1.validTime })
    }
    
    public func get<T>(_ keyPath: KeyPath<Parameter, T>, for name: Parameter.Name) -> T {
        return forecast.parameter(byName: name) {
            $0[keyPath: keyPath]
        }
    }
    
    public func get(_ name: Parameter.Name) -> Parameter {
        return forecast.parameter(byName: name) { $0 }
    }
    
    public func getAll<T>(_ keyPath: KeyPath<Parameter, T>, for name: Parameter.Name) -> [T] {
        return forecasts.map {
            $0.parameter(byName: name) {
                $0[keyPath: keyPath]
            }
        }
    }
    
    public func getAll(_ name: Parameter.Name) -> [(validTime: Date, parameter: Parameter)] {
        return forecasts.map {
            ($0.validTime, $0.parameter(byName: name) { $0 })
        }
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
