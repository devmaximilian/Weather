//
// Resource.swift
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

public struct Resource: Codable {
    public let geoBox: GeoBox
    public let key: String
    public let title: String
    public let summary: String
    public let link: [Link]
}

public extension Resource {
    var codes: Link? {
        return self.link.filter { (link) -> Bool in
            link.rel == "codes"
        }.first
    }

    var parameter: Link? {
        return self.link.filter { (link) -> Bool in
            link.rel == "parameter"
        }.first
    }
}

public extension Array where Array.Element == Resource {
    // MARK: Air temperature

    var minAirTemperature: Resource? {
        return self.filter { (resource) -> Bool in
            resource.key == "26"
        }.first
    }

    var maxAirTemperature: Resource? {
        return self.filter { (resource) -> Bool in
            resource.key == "27"
        }.first
    }

    var currentAirTemperature: Resource? {
        return self.filter { (resource) -> Bool in
            resource.key == "1"
        }.first
    }

    // MARK: Air pressure

    var currentAirPressure: Resource? {
        return self.filter { (resource) -> Bool in
            resource.key == "9"
        }.first
    }

    // MARK: Percipitation

    var percipitation: Resource? {
        return self.filter { (resource) -> Bool in
            resource.key == "17"
        }.first
    }

    var currentPercipitationIntensity: Resource? {
        return self.filter { (resource) -> Bool in
            resource.key == "15"
        }.first
    }

    var currentPercipitationVolume: Resource? {
        return self.filter { (resource) -> Bool in
            resource.key == "14"
        }.first
    }

    var percipitationVolume: Resource? {
        return self.filter { (resource) -> Bool in
            resource.key == "5"
        }.first
    }

    // MARK: Weather

    var currentWeather: Resource? {
        return self.filter { (resource) -> Bool in
            resource.key == "13"
        }.first
    }

    // MARK: Humidity

    var currentHumidity: Resource? {
        return self.filter { (resource) -> Bool in
            resource.key == "6"
        }.first
    }

    // MARK: Sikt

    var currentSight: Resource? {
        return self.filter { (resource) -> Bool in
            resource.key == "12"
        }.first
    }

    // MARK: Sunlight

    var currentSunlight: Resource? {
        return self.filter { (resource) -> Bool in
            resource.key == "10"
        }.first
    }

    // MARK: Clouds

    var currentClouds: Resource? {
        return self.filter { (resource) -> Bool in
            resource.key == "16"
        }.first
    }

    // MARK: Wind speed

    var currentWindSpeed: Resource? {
        return self.filter { (resource) -> Bool in
            resource.key == "4"
        }.first
    }

    // MARK: Wind direction

    var currentWindDirection: Resource? {
        return self.filter { (resource) -> Bool in
            resource.key == "3"
        }.first
    }
}
