//
//  AlertPresenter.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 12.06.2023.
//

import UIKit

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
}

final class AlertPresenter {

    private weak var controller: UIViewController?

    init(controller: UIViewController, accessibilityIdentifier: String = "alert") {
        self.controller = controller
    }

    func showAlert(alert: AlertModel, completion: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: alert.title,
                                      message: alert.message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: alert.buttonText, style: .default, handler: completion)
        alertController.addAction(action)
        controller?.present(alertController, animated: true, completion: nil)
    }
}
