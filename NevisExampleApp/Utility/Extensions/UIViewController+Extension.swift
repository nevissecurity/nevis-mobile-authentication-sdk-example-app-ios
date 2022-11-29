//
// Nevis Mobile Authentication SDK Example App
//
// Copyright © 2022. Nevis Security AG. All rights reserved.
//

import KRProgressHUD
import UIKit

extension UIViewController {

	/// Sets up a loading view and presents above self.
	func showLoading() {
		KRProgressHUD.show(withMessage: L10n.Screen.loading)
	}

	/// Dismisses the loading view.
	func dismissLoading() {
		KRProgressHUD.dismiss()
	}
}
