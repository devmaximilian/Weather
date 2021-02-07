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
        case msl

        /// Air temperature
        case t

        /// Horizontal visibility
        case visibility

        /// Wind direction
        case wd

        /// Wind speed
        case ws

        /// Relative humidity
        case r

        /// Thunder probability
        case tstm

        /// Mean value of total cloud cover
        case tcc_mean

        /// Mean value of low level cloud cover
        case lcc_mean

        /// Mean value of medium level cloud cover
        case mcc_mean

        /// Mean value of high level cloud cover
        case hcc_mean

        /// Wind gust speed
        case gust

        /// Minimum precipitation intensity
        case pmin

        /// Maximum precipitation intensity
        case pmax

        /// Percent of precipitation in frozen form
        case spp

        /// Precipitation category
        case pcat

        /// Mean precipitation intensity
        case pmean

        /// Median precipitation intensity
        case pmedian

        /// Weather symbol
        case wsymb2

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
