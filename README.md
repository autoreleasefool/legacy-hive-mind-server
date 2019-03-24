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
    * You may need to update `Sources/App/HiveMind/HiveMindProcess` to point to your clone of [HiveMind](https://github.com/josephroquedev/hivemind)
        * Currently, the app assumes the two repositories have been cloned within the same parent directory
4. That's it! You've got a server running.

### Requirements

* Swift 4.1+
* macOS 10.13+
* [Vapor](https://vapor.codes)

## Contributing

1. Install SwiftLint for styling conformance:
    * `brew install swiftlint`
    * Run `swiftlint` from the root of the repository.
    * There should be no errors or violations. If there are, please fix them before opening a PR.
2. Open a PR with your changes 👍
