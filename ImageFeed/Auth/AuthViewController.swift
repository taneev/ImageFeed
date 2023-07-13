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

    private lazy var authButton: UIButton = {setupAuthButton()}()
    private lazy var unsplashLogo: UIView = {setupUnsplashLogo()}()

    weak var delegate: AuthViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ypBlack
        view.addSubview(unsplashLogo)

        view.addSubview(authButton)
        authButton.addTarget(self, action: #selector(authButtonDidTapped), for: .touchUpInside)

        setupLayout()
    }
}

// MARK: - View
extension AuthViewController {

    @objc private func authButtonDidTapped() {
        let webViewController = WebViewViewController()
        let webViewPresenter = WebViewPresenter()

        webViewPresenter.viewController = webViewController
        webViewController.presenter = webViewPresenter
        webViewController.delegate = self

        navigationController?.navigationBar.isHidden = true
        navigationController?.pushViewController(webViewController, animated: true)
    }

    private func setupAuthButton() -> UIButton {
        let button = UIButton()
        button.backgroundColor = .ypWhite

        button.setTitle("Войти", for: .normal)
        button.setTitleColor(.ypBlack, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)

        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true

        return button
    }

    private func setupUnsplashLogo() -> UIImageView {
        let logo = UIImageView()
        logo.image = UIImage(named: "auth_screen_logo") ?? UIImage()
        return logo
    }

    private func setupLayout() {
        authButton.translatesAutoresizingMaskIntoConstraints = false
        unsplashLogo.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
            [
                unsplashLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                unsplashLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                unsplashLogo.heightAnchor.constraint(equalToConstant: 60),
                unsplashLogo.widthAnchor.constraint(equalTo: unsplashLogo.heightAnchor),

                authButton.heightAnchor.constraint(equalToConstant: 48),
                authButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                authButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                authButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -124)
            ]
        )
    }
}


// MARK: - WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        vc.navigationController?.popViewController(animated: true)
        fetchOAuthToken(authCode: code)
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
                                       cancelButtonText: "Ок")
                let alertPresenter = AlertPresenter(controller: self)
                alertPresenter.showAlert(alert: alert)
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
}
