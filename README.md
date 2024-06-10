# SeaCat-iOS-G3
SeaCat SDK for iOS (3rd generation)

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate SeaCat into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'SeaCat', '~> 24.24.01'
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. It is in early development, but SeaCat does support its use on supported platforms.

Once you have your Swift package set up, adding SeaCat as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/TeskaLabs/SeaCat-iOS-G3.git", .upToNextMajor(from: "24.24.01"))
]
```

### Swift Package Manager (via Xcode)

Navigate Xcode`s top menu `File > Swift Packages > Add Package Dependency`. 
Then in dialog use url __https://github.com/TeskaLabs/SeaCat-iOS-G3.git__ and version __24.24.01__.

## Usage

Working with SeaCat is simple.

```swift
import SeaCat

// 1. Configure SeaCat with your PKI URL.
let seacat = SeaCat(apiURL: "https://pki.seacat.io/seacat-demo/seacat")

// 2. Check whenever is SeaCat ready (Bool).
seacat.ready

// 3. Create URLSession with SeaCat identity.
let session = seacat.createURLSession()
```

Additionaly you might need this too.

```swift
// Get SeaCat identity (String). Ideal for logging or debuging clients.
seacat.identity?.identity

// Revoke current identity in PKI (e.g. Certificate).
seacat.identity?.revoke()

// When you revoke identity but you want continue with new identity.
seacat.identity?.enroll()
```

## Notice

It is important to create `URLSession` after SeaCat become ready. If you revoke
identity and then enroll with new one then you need create new `URLSession` too.

## License

SeaCat is released under the BSD-3-Clause License. [See LICENSE](https://github.com/TeskaLabs/SeaCat-iOS-G3/blob/master/LICENSE) for details.
