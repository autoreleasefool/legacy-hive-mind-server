![Logo](media/HiveServer.png)

# HiveAI Server

Backend access to the HiveMind.

## Getting started

1. First, you'll need to grab a couple other repos to build the entire system and play a game of Hive against the HiveMind.
    * [Hive Client](https://github.com/josephroquedev/hive-client)
    * [Hive Server](https://github.com/josephroquedev/hive-server)
    * [HiveMind](https://github.com/josephroquedev/hivemind)
2. Build the project
    * `vapor xcode` to create Xcode project for contributing
    * `swift build -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.13"` to build without Xcode
3. Start the server
    * Start the `Run` scheme with Xcode
    * Or, `.build/x86_64-apple-macosx10.13/debug/Run` to run without Xcode
4. That's it! You've got a server running.

By default, the server will communicate with the HiveMind AI on port `8081`. This can be configured when starting your instance of the server and the [HiveMind](https://github.com/josephroquedev/hivemind), or you can add your own AI by following the `HiveMind` example in `Sources/App/HiveMind` 

### Requirements

* Swift 5.0+
* macOS 10.13+
* [Vapor](https://vapor.codes)

## Contributing

1. Install SwiftLint for styling conformance:
    * `brew install swiftlint`
    * Run `swiftlint` from the root of the repository.
    * There should be no errors or violations. If there are, please fix them before opening a PR.
2. Open a PR with your changes 👍
