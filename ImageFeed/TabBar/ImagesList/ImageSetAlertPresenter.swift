//
//  ImageSetAlertPresenter.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 09.07.2023.
//

import UIKit

struct ImageSetAlertModel {
    let title: String
    let message: String
    let RetryButtonText: String
    let CancelButtonText: String
}

final class ImageSetAlertPresenter {
    private weak var controller: UIViewController?

    init(controller: UIViewController) {
        self.controller = controller
    }

    func showAlert(alert: ImageSetAlertModel, retryCompletion completion: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: alert.title,
                                                message: alert.message,
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: alert.CancelButtonText, style: .cancel)
        alertController.addAction(cancelAction)

        let retryAction = UIAlertAction(title: alert.RetryButtonText, style: .default, handler: completion)
        alertController.addAction(retryAction)

        controller?.present(alertController, animated: true, completion: nil)
    }
}
