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
