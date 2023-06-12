//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 03.06.2023.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewControllerDelegate(_ vc: AuthViewController, didGetToken token: String)
}

final class AuthViewController: UIViewController {

    private let webViewControllerSegueID = "ShowWebView"
    private let authService = OAuth2Service()

    weak var delegate: AuthViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if segue.identifier == webViewControllerSegueID {
            guard let webViewViewController = segue.destination as? WebViewViewController
            else {fatalError("Failed to prepare for \(webViewControllerSegueID)")}

            webViewViewController.delegate = self
        }
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        vc.dismiss(animated: true) {[weak self] in
            self?.fetchOAuthToken(authCode: code)
        }
    }

    private func fetchOAuthToken(authCode code: String) {
        authService.fetchAuthToken(code: code) {[weak self] result in
            guard let self else {return}
            switch result {
            case .success(let token):
                self.delegate?.authViewControllerDelegate(self, didGetToken: token)
            case .failure:
                UIBlockingProgressHUD.dismiss()
                let alert = AlertModel(title: "Что-то пошло не так(",
                                       message: "Не удалось войти в систему",
                                       buttonText: "Ок")
                let alertPresenter = AlertPresenter(controller: self)
                alertPresenter.showAlert(alert: alert)
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
