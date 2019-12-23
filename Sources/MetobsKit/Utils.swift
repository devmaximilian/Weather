//
// Utils.swift
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

/// A `Future` wrapper for a `Value`
open class Future<Value> {
    internal var result: Result<Value>? {
        // Observe whenever a result is assigned, and report it
        didSet { self.result.map(self.report) }
    }

    private lazy var callbacks = [(Result<Value>) -> ()]()

    /// Subscribe to `Result` updates
    /// - Parameter callback: A closure providing an updated `Result`
    public func observe(with callback: @escaping (Result<Value>) -> ()) {
        self.callbacks.append(callback)

        // If a result has already been set, call the callback directly
        self.result.map(callback)
    }

    /// Notify subscribers that the `Result` was updated
    private func report(result: Result<Value>) {
        for callback in self.callbacks {
            callback(result)
        }
    }
}

/// A `Promise` that will either be honored or broken
public final class Promise<Value>: Future<Value> {
    // MARK: Initializer

    /// Initializes a new `Promise` for `Value`
    /// - Parameter value: The promised `Value`
    public init(value: Value? = nil, error: Error? = nil) {
        super.init()

        // If the value was already known at the time the promise
        // was constructed, we can report the value directly
        result = value.map(Result.value)

        // If an error was already known at the time the promise
        // was constructed, we can report it directly
        guard let error = error else {
            return
        }
        result = .error(error)
    }

    // MARK: Public methods

    /// Resolve the `Promise`, equivalent to honoring it
    /// - Parameter value: The promised `Value`
    public func resolve(with value: Value) {
        result = .value(value)
    }

    /// Reject the `Promise`, equivalent to breaking it
    /// - Parameter error: The reason the `Promise` was rejected
    public func reject(with error: Error) {
        result = .error(error)
    }
}

/// A `Result` for a `Future<Value>`
public enum Result<Value> {
    /// Provides a `Value`
    case value(Value)

    /// Provides an `Error`
    case error(Error)
}

/// An extension to the encodable protocol
public extension Encodable {
    /// A method for encodable types that encodes itself
    func encoded() throws -> Data {
        return try JSONEncoder().encode(self)
    }
}

/// An extension to data to decode types
public extension Data {
    /// A property for data that attempts to decode into the provided type
    func decoded<T: Decodable>() throws -> T {
        return try JSONDecoder().decode(T.self, from: self)
    }
}
