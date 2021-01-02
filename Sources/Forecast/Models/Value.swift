//
// Value.swift
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

/// A `Value` value representation for a `Forecast` parameter
public struct Value: Codable {
    /// A `Parameter` type representing the underlying value's type
    public let name: Parameter

    /// A `Level` representing the measurement's reference distance
    public let levelType: Level

    /// The distance above the `Level`
    public let level: Int

    /// The unit the value can be measured in
    public let unit: String

    /// An array of raw parameter values
    public let values: [Double]
}

extension Value {
    /// The first value of the raw parameter values
    public var value: Double {
        return self.values.first ?? 0
    }
    
    /// Unknown `Value`
    public static var unknown: Value {
        return .init(name: .unknown, levelType: .unknownLevel, level: 0, unit: "", values: [])
    }
}
