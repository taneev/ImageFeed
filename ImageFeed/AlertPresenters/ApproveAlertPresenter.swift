//
//  ApproveAlertPresenter.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 09.07.2023.
//

import UIKit

struct ApproveAlertModel {
    let title: String
    let message: String
    let ApproveButtonText: String
    let CancelButtonText: String
}

final class ApproveAlertPresenter {
    private weak var controller: UIViewController?

    init(controller: UIViewController) {
        self.controller = controller
    }

    func showAlert(alert: ApproveAlertModel, retryCompletion completion: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: alert.title,
                                                message: alert.message,
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: alert.CancelButtonText, style: .cancel)
        alertController.addAction(cancelAction)

        let approveAction = UIAlertAction(title: alert.ApproveButtonText, style: .default, handler: completion)
        alertController.addAction(approveAction)

        controller?.present(alertController, animated: true, completion: nil)
    }
}
