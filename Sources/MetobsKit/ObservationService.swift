//
// ObservationService.swift
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

public class ObservationService {
    private var version: DirectoryVersion
    private var baseURL: URL
    private var networkService: URLSession = URLSession.shared

    public init(version: DirectoryVersion, baseURL: URL? = nil) {
        self.version = version
        self.baseURL = baseURL ?? MetobsKit.endpoint
    }

    private func request<T: Decodable>(url: URL) -> Promise<T> {
        let promise = Promise<T>()

        self.networkService.dataTask(with: url) { data, response, error in

            // Make sure request did not result in error
            if let error = error {
                return promise.reject(with: error)
            }

            // Make sure acceptable response code present on response
            if let response = response as? HTTPURLResponse {
                if 400 ... 599 ~= response.statusCode {
                    let error = URLError(.init(rawValue: response.statusCode))
                    return promise.reject(with: error)
                }
            }

            // Make sure the request returned data
            guard let data = data else {
                return promise.reject(with: URLError(.zeroByteResource))
            }

            // Attempt to decode data
            do {
                let value: T = try data.decoded()
                return promise.resolve(with: value)
            } catch {
                return promise.reject(with: error)
            }
        }.resume()

        return promise
    }

    public func getDirectory() -> Promise<Directory> {
        let promise: Promise<Directory> = self.request(url: self.baseURL.appendingPathComponent("api.json"))

        return promise
    }

    public func getResourceDirectory() -> Promise<ResourceDirectory> {
        let promise: Promise<ResourceDirectory> = self.request(url: self.baseURL.appendingPathComponent("api/version/\(self.version.string).json"))

        return promise
    }
}
