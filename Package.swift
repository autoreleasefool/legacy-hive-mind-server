// swift-tools-version:5.0
import PackageDescription

let package = Package(
	name: "HiveServer",
	products: [
		.library(name: "HiveServer", targets: ["App"])
	],
	dependencies: [
		.package(url: "https://github.com/vapor/vapor.git", from: "3.3.0"),
		.package(url: "https://github.com/josephroquedev/hive-engine.git", .branch("master")),
		.package(url: "https://github.com/daltoniam/Starscream.git", from: "3.1.0")
	],
	targets: [
		.target(name: "App", dependencies: ["Vapor", "HiveEngine", "Starscream"]),
		.target(name: "Run", dependencies: ["App"]),
		.testTarget(name: "AppTests", dependencies: ["App"])
	]
)
