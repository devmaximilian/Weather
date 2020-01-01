# MetobsKit

This package is a wrapper for the PMP3g API provided by [SMHI](https://smhi.se).

### Usage

Add MetobsKit to your `Package.swift` manifest.

```swift
...
/// Append the package to the list of dependencies
dependencies: [
    .package(url: "https://github.com/devmaximilian/MetobsKit.git", from: "0.3.0")
],

/// Append the library to the list of target dependencies
targets: [
    .target(
        name: "MyProject",
        dependencies: ["MetobsKit"])
]
...
```

Note that this is just a simple example demonstrating how the package can be used.

```swift
/// Get an instance of the weather forecast service
let service = ForecastService.shared

/// Request the current weather forecast for Stockholm
service.get(latitude: 59.3258414, longitude: 17.7018733)
    .observe { result in
        switch result {
        case let .value(observation):
            /// Use the current forecast
            guard let forecast = observation.current else {
                return
            }

            /// Get the air temperature
            let temperature = forecast.get(parameter: .airTemperature)

            /// Use the air temperature in some way
        case let .error(error):
            /// This error should be handled in a real use-case
            fatalError("Failed to get forecast!")
        }
    }
```

### Attribution

This package utilizes data provided by [SMHI](https://smhi.se).

### Terms of use

Make sure to read SMHI:s [terms of use](https://www.smhi.se/data/oppna-data/villkor-for-anvandning) before using this package.

### Legal disclaimer

The developer and this package are not affiliated with or endorsed by SMHI. Any products and services provided through this package are not supported or warrantied by SMHI.

### License

See LICENSE for license details concerning this package and SMHI:s [terms of use](https://www.smhi.se/data/oppna-data/villkor-for-anvandning) for license details concerning the data provided by their API.
