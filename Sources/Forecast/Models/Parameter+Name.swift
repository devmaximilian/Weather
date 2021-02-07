//
// Parameter+Name.swift
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

extension Parameter {
    public enum Name: String, Decodable {
        /// Air pressure
        case airPressure = "msl"

        /// Air temperature
        case airTemperature = "t"

        /// Horizontal visibility
        case visibility = "visibility"

        /// Wind direction
        case windDirection = "wd"

        /// Wind speed
        case windSpeed = "ws"

        /// Relative humidity
        case relativeHumidity = "r"

        /// Thunder probability
        case thunderProbability = "tstm"

        /// Mean value of total cloud cover
        case cloudCoverTotal = "tcc_mean"

        /// Mean value of low level cloud cover
        case cloudCoverLow = "lcc_mean"

        /// Mean value of medium level cloud cover
        case cloudCoverMedium = "mcc_mean"

        /// Mean value of high level cloud cover
        case cloudCoverHigh = "hcc_mean"

        /// Wind gust speed
        case windGustSpeed = "gust"

        /// Minimum precipitation intensity
        case precipitationIntensityMin = "pmin"

        /// Maximum precipitation intensity
        case precipitationIntensityMax = "pmax"

        /// Percent of precipitation in frozen form
        case frozenPrecipitation = "spp"

        /// Precipitation category
        case precipitationCategory = "pcat"

        /// Mean precipitation intensity
        case precipitationIntensityMean = "pmean"

        /// Median precipitation intensity
        case precipitationIntensityMedian = "pmedian"

        /// Weather symbol
        case weatherSymbol = "wsymb2"

        /// Unknown parameter
        case unknown = ""
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            
            guard let name = try? Name(rawValue: container.decode(String.self)) else {
                self = .unknown
                return
            }
            self = name
        }
    }
}
