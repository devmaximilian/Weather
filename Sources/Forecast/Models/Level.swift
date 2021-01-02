//
// Level.swift
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

/// A `Level` representing the measurement's base-level
public enum Level: String {
    /// Above sea level
    case seaLevel = "hmsl"

    /// Above ground level
    case groundLevel = "hl"

    /// Above unknown level
    case unknownLevel
}

/// An extension adding `Codable` protocol conformance to `Level`
extension Level: Codable {
    // MARK: Initializer

    /// Initialize a new `Level` using `Decoder`
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        /// Attempt to decode received value
        guard let value = try? container.decode(String.self) else {
            self = .unknownLevel
            return
        }

        /// Map raw value to enum representation
        switch value.lowercased() {
        case "hmsl":
            self = .seaLevel
        case "hl":
            self = .groundLevel
        default:
            self = .unknownLevel
        }
    }

    // MARK: Public methods

    /// Encode `Level` using `Encoder`
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        do {
            try container.encode(self.rawValue)
        } catch {
            try container.encode("unknown")
        }
    }
}
