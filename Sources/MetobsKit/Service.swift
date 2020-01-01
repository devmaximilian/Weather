//
// Service.swift
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

/// A service that provides weather forecasts
public class ForecastService: NSObject {
    // MARK: Private properties

    /// The service endpoint to send requests to
    private var serviceEndpoint: String {
        return "https://opendata-download-metfcst.smhi.se/api/category/pmp3g/version/2/geotype/point/lon/LONGITUDE/lat/LATITUDE/data.json"
    }

    /// A shared instance of forecast service
    private static var sharedInstance: ForecastService?

    // MARK: Private functions

    /// Wrapps a network request as a `Promise<Value>`
    private func request<Value: Decodable>(url: URL) -> Promise<Value> {
        let promise = Promise<Value>()

        URLSession.shared.dataTask(with: url) { data, response, error in
            // Make sure request did not result in an error
            if let error = error {
                return promise.reject(with: error)
            }

            // Make sure an acceptable response code is present on the response
            if let response = response as? HTTPURLResponse {
                if 400 ... 599 ~= response.statusCode {
                    let error = URLError(.init(rawValue: response.statusCode))
                    return promise.reject(with: error)
                }
            }

            // Make sure the request returned data (and not an empty response)
            guard let data = data else {
                return promise.reject(with: URLError(.zeroByteResource))
            }

            // Attempt to decode JSON data from the response
            do {
                let value: Value = try data.decoded()
                return promise.resolve(with: value)
            } catch {
                return promise.reject(with: error)
            }
        }.resume()

        return promise
    }

    /// Constructs a `URL` to use when requesting forecasts
    /// - Parameters:
    ///   - latitude: The latitude to use for request
    ///   - longitude: The longitude to use for request
    private func buildURL(latitude: Double, longitude: Double) -> Promise<URL> {
        // Remove decimals exceeding six positions as it will cause a 404 response
        let values: (lat: Double, lon: Double) = (
            lat: latitude.rounded(toPrecision: 6),
            lon: longitude.rounded(toPrecision: 6)
        )

        let constructedURL = self.serviceEndpoint
            .replacingOccurrences(of: "LONGITUDE", with: "\(values.lon)")
            .replacingOccurrences(of: "LATITUDE", with: "\(values.lat)")

        // Construct the URL
        guard let url = URL(string: constructedURL) else {
            return Promise<URL>(value: nil, error: URLError(.badURL))
        }

        return Promise<URL>(value: url)
    }

    // MARK: Public functions

    /// Get the weather forecast `Observation` for a specific set of  coordinates
    /// - Note: See https://www.smhi.se/data/utforskaren-oppna-data/meteorologisk-prognosmodell-pmp3g-2-8-km-upplosning-api
    ///         for information about limitations (such as coordinate limitations)
    /// - Parameters:
    ///   - latitude: The coordinate latitude
    ///   - longitude: The coordinate longitude
    /// - Returns: A `Promise` with the value `Observation`
    public func get(latitude: Double, longitude: Double) -> Promise<Observation> {
        let observationPromise: Promise<Observation> = Promise<Observation>()

        // Request the forecast for the provided coordinates
        let urlPromise = self.buildURL(latitude: latitude, longitude: longitude)

        // Observe the request and forward the result
        urlPromise.observe { urlResult in
            switch urlResult {
            case let .value(value):
                let networkPromise: Promise<Observation> = self.request(url: value)
                networkPromise.observe { networkResult in
                    switch networkResult {
                    case let .value(value):
                        observationPromise.resolve(with: value)
                    case let .error(error):
                        observationPromise.reject(with: error)
                    }
                }
            case let .error(error):
                observationPromise.reject(with: error)
            }
        }

        return observationPromise
    }

    // MARK: Shared instance

    /// A shared forecast-service instance
    public static var shared: ForecastService {
        guard let existingInstance = ForecastService.sharedInstance else {
            let instance = ForecastService()
            ForecastService.sharedInstance = instance
            return instance
        }
        return existingInstance
    }
}
