//
// Forecast.swift
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

import struct Foundation.Date


/// A `Forecast` is a collection of `Parameter`s
public struct Forecast: Decodable {
    /// A timestamp for when the `Forecast` is valid
    public let validTime: Date

    /// An array of `Value` instances
    internal let parameters: [Parameter]

    /// Get a `Parameter` by name.
    ///
    /// - Parameter parameter: The `Parameter` to get `Value` for
    public func get(_ name: Parameter.Name) -> Parameter {
        return self.parameters.first { (value) -> Bool in
            value.name == name
        }.unsafelyUnwrapped
    }
    
    /// Get `Value` for a `Parameter`
    ///
    /// - Parameter parameter: The `Parameter` to get `Value` for
    public func get<T>(_ name: Parameter.Name, _ keyPath: KeyPath<Parameter, T>) -> T {
        return self.get(name)[keyPath: keyPath]
    }
}
