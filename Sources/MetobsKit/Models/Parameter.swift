//
// Parameter.swift
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

/// A `Parameter` type
/// - Note: See https://opendata.smhi.se/apidocs/metfcst/parameters.html
public enum Parameter: String {
    /// Air pressure
    case airPressure = "msl"

    /// Air temperature
    case airTemperature

    /// Horizontal visibility
    case visibility

    /// Wind direction
    case windDirection

    /// Wind speed
    case windSpeed

    /// Relative humidity
    case relativeHumidity

    /// Thunder probability
    case thunderProbability

    /// Mean value of total cloud cover
    case cloudCoverTotal

    /// Mean value of low level cloud cover
    case cloudCoverLow

    /// Mean value of medium level cloud cover
    case cloudCoverMedium

    /// Mean value of high level cloud cover
    case cloudCoverHigh

    /// Wind gust speed
    case windGustSpeed

    /// Minimum precipitation intensity
    case precipitationIntensityMin

    /// Maximum precipitation intensity
    case precipitationIntensityMax

    /// Percent of precipitation in frozen form
    case frozenPrecipitation

    /// Precipitation category
    case precipitationCategory

    /// Mean precipitation intensity
    case precipitationIntensityMean

    /// Median precipitation intensity
    case precipitationIntensityMedian

    /// Weather symbol
    case weatherSymbol

    /// Unknown parameter
    case unknown
}

/// An extension adding `Codable` protocol conformance to `Parameter`
extension Parameter: Codable {
    // MARK: Initializer

    /// Initialize a new `Parameter` using `Decoder`
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        /// Attempt to decode received value
        guard let value = try? container.decode(String.self) else {
            self = .unknown
            return
        }

        /// Map raw value to enum representation
        switch value.lowercased() {
        case "msl":
            self = .airPressure
        case "t":
            self = .airTemperature
        case "vis":
            self = .visibility
        case "wd":
            self = .windDirection
        case "ws":
            self = .windSpeed
        case "r":
            self = .relativeHumidity
        case "tstm":
            self = .thunderProbability
        case "tcc_mean":
            self = .cloudCoverTotal
        case "lcc_mean":
            self = .cloudCoverLow
        case "mcc_mean":
            self = .cloudCoverMedium
        case "hcc_mean":
            self = .cloudCoverHigh
        case "gust":
            self = .windGustSpeed
        case "pmin":
            self = .precipitationIntensityMin
        case "pmax":
            self = .precipitationIntensityMax
        case "spp":
            self = .frozenPrecipitation
        case "pcat":
            self = .precipitationCategory
        case "pmean":
            self = .precipitationIntensityMean
        case "pmedian":
            self = .precipitationIntensityMedian
        case "wsymb2":
            self = .weatherSymbol
        default:
            self = .unknown
        }
    }

    // MARK: Public methods

    /// Encode `Parameter` using `Encoder`
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        do {
            try container.encode(self.rawValue)
        } catch {
            try container.encode("unknown")
        }
    }
}
