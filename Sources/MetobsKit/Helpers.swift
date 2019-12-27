//
// Helpers.swift
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

extension Double {
    func rounded(toPrecision precision: Int) -> Double {
        let multiplier: Double = pow(10, Double(precision))
        return (self * multiplier).rounded() / multiplier
    }
}

internal func buildURL(latitude: Double, longitude: Double) -> Promise<URL> {
    // Remove decimals exceeding six positions as it will cause a 404 response
    let values: (lat: Double, lon: Double) = (
        lat: latitude.rounded(toPrecision: 6),
        lon: longitude.rounded(toPrecision: 6)
    )

    guard let url = URL(string: "https://opendata-download-metfcst.smhi.se/api/category/pmp3g/version/2/geotype/point/lon/\(values.lon)/lat/\(values.lat)/data.json") else {
        return Promise<URL>(value: nil, error: URLError(.badURL))
    }

    return Promise<URL>(value: url)
}
