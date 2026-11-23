//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2026 Nevis Security AG. All rights reserved.
//

import SwiftUI
import UIKit

/// The principal view controller of the share extension; hosts ``ShareView``.
final class ShareScreen: UIViewController {
	// MARK: - Properties

	/// The model driving ``ShareView``.
	private let model = ShareModel(authenticationService: AuthenticationServiceImpl(configurationLoader: ConfigurationLoaderImpl(environment: .authenticationCloud)))

	// MARK: - UIViewController

	/// Embeds ``ShareView`` and completes the extension request when the user is done.
	override func viewDidLoad() {
		super.viewDidLoad()

		model.onDone = { [weak self] in self?.extensionContext?.completeRequest(returningItems: [], completionHandler: nil) }

		let host = UIHostingController(rootView: ShareView(model: model))
		addChild(host)
		host.view.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(host.view)
		NSLayoutConstraint.activate([
			host.view.topAnchor.constraint(equalTo: view.topAnchor),
			host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
		])
		host.didMove(toParent: self)
	}
}
