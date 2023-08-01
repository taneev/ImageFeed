//
//  ApproveAlertPresenter.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 09.07.2023.
//

import UIKit

struct AlertModel {
    let title: String
    let message: String
    let cancelButtonText: String
    let approveButtonText: String?

    init(title: String, message: String, cancelButtonText: String, approveButtonText: String? = nil) {
        self.title = title
        self.message = message
        self.cancelButtonText = cancelButtonText
        self.approveButtonText = approveButtonText
    }
}

final class AlertPresenter {
    private weak var controller: UIViewController?

    init(controller: UIViewController) {
        self.controller = controller
    }

    func showAlert(alert: AlertModel, retryCompletion completion: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: alert.title,
                                                message: alert.message,
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: alert.cancelButtonText, style: .cancel, handler: completion)
        alertController.addAction(cancelAction)

        if let approveButtonText = alert.approveButtonText {
            let approveAction = UIAlertAction(title: approveButtonText, style: .default, handler: completion)
            alertController.addAction(approveAction)
        }

        controller?.present(alertController, animated: true, completion: nil)
    }
}
