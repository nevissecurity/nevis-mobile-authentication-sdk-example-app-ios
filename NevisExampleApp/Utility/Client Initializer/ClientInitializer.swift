//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import Foundation

@MainActor
protocol ClientInitializer {
	func initialize() async throws
}
