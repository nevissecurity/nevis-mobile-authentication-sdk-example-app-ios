// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "NevisExampleShared",
	defaultLocalization: "en",
	platforms: [
		.iOS(.v15),
		.watchOS(.v10),
		// Only to run the unit tests with `swift test`.
		.macOS(.v13),
	],
	products: [
		.library(name: "NevisExampleShared", targets: ["NevisExampleShared"])
	],
	targets: [
		.target(
			name: "NevisExampleShared",
			resources: [.process("Resources")]
		),
		.testTarget(
			name: "NevisExampleSharedTests",
			dependencies: ["NevisExampleShared"]
		),
	]
)
