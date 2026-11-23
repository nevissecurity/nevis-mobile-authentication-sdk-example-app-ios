//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import Foundation

/// A convenient timer that is run until the defined `TimeInterval`, then invalidated.
/// Calls the given `intervalCallback` periodically in each `refreshInterval`, until the timer is invalidated.
@MainActor
final class InteractionCountDownTimer {

	// MARK: - Properties

	/// The interval for how long the timer should run.
	let timerLifeTime: TimeInterval

	/// The interval when to call the `intervalCallback`.
	let refreshInterval: TimeInterval

	/// The callback that is called providing the remaining time in the timer.
	let intervalCallback: (@MainActor (Int) -> ())?

	/// Tells whether the timer is valid and running.
	var isValid: Bool {
		timer?.isValid ?? false
	}

	/// The internal timer instance.
	private var timer: Timer?

	/// The timer time interval.
	private var endOfTimer: TimeInterval = 0.0

	// MARK: - Initialization

	/// Creates a new instance.
	///
	/// - Parameters:
	///   - timerLifeTime: The interval for how long the timer should run.
	///   - refreshInterval: The interval when to call the `intervalCallback`. Default value is 1.0.
	///   - intervalCallback: The callback that is called providing the remaining time in the timer. Default value is *nil*.
	init(
		timerLifeTime: TimeInterval,
		refreshInterval: TimeInterval = 1.0,
		intervalCallback: (@MainActor (Int) -> ())? = nil
	) {
		self.timerLifeTime = timerLifeTime
		self.refreshInterval = refreshInterval
		self.intervalCallback = intervalCallback
	}
}

// MARK: - Actions

extension InteractionCountDownTimer {

	/// Starts the timer.
	func start() {
		timer?.invalidate()
		endOfTimer = Date(timeIntervalSinceNow: timerLifeTime).timeIntervalSinceReferenceDate
		// The timer is scheduled on the main run loop, so it fires on the main thread.
		timer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { _ in
			MainActor.assumeIsolated {
				self.tick()
			}
		}
	}

	/// Cancels the timer.
	func cancel() {
		timer?.invalidate()
	}
}

// MARK: - Private Interface

private extension InteractionCountDownTimer {

	/// Calculates the remaining time, invalidates the timer when it is over and notifies the callback.
	func tick() {
		var remainingTime = round(endOfTimer - Date().timeIntervalSinceReferenceDate)
		if remainingTime < 1 {
			remainingTime = 0
			timer?.invalidate()
		}
		intervalCallback?(Int(remainingTime))
	}
}
