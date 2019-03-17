// swift-tools-version:4.0
import PackageDescription

let package = Package(
	name: "HiveServer",
	products: [
		.library(name: "HiveServer", targets: ["App"])
	],
	dependencies: [
		.package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
		.package(url: "https://github.com/josephroquedev/hive-engine.git", .branch("master"))
	],
	targets: [
		.target(name: "App", dependencies: ["Vapor", "HiveEngine"]),
		.target(name: "Run", dependencies: ["App"]),
		.testTarget(name: "AppTests", dependencies: ["App"])
	]
)
