//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 04.06.2023.
//

import UIKit
import ProgressHUD
import SwiftKeychainWrapper

final class SplashViewController: UIViewController {

    private let tokenKey = "UnsplashBearerToken"
    private let profileService = ProfileService.shared
    private lazy var splashLogoImageView: UIImageView = {createSplashLogoImageView()}()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ypBlack
        view.addSubview(splashLogoImageView)

        NSLayoutConstraint.activate(
            [
                splashLogoImageView.heightAnchor.constraint(equalToConstant: 75),
                splashLogoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                splashLogoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ]
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let token = KeychainWrapper.standard.string(forKey: tokenKey) {
            UIBlockingProgressHUD.show()
            profileFetch(token: token)
        }
        else {
            presentAuthViewController()
        }
    }

    private func createSplashLogoImageView() -> UIImageView {
        let logoImage = UIImage(systemName: "practicumLogo")
        let logoImageView = UIImageView(image: logoImage)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        return logoImageView
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let tabBarViewController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? TabBarController else {
            assertionFailure("Could not instantiate TabBarController")
            return
        }
        window.rootViewController = tabBarViewController
    }

}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewControllerDelegate(_ vc: AuthViewController, didGetToken token: String) {
        // сохраняем полученный токен
        let isSuccess = KeychainWrapper.standard.set(token, forKey: tokenKey)
        if !isSuccess {
            assertionFailure("Bearer token not saved in keychain")
        }

        profileFetch(token: token)
        dismiss(animated: true)
    }

    private func presentAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "authViewController") as? AuthViewController
        else {
            assertionFailure("AuthViewController couldn't be initialized")
            return
        }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }

    private func alertAndSwitchToAuthViewController() {
        let alert = AlertModel(title: "Что-то пошло не так(",
                               message: "Не удалось войти в систему",
                               buttonText: "Ок")
        let alertPresenter = AlertPresenter(controller: self)
        alertPresenter.showAlert(alert: alert) {[weak self] _ in
            self?.presentAuthViewController()
        }
    }

    private func profileFetch(token: String) {
        profileService.fetchProfile(token) {[weak self] result in
            guard let self else {return}

            switch result {
            case .success(let profile):
                // бросаем вдогонку запрос чтения url аватара, но не ждем здесь ответа (и ошибок)
                ProfileImageService.shared.fetchProfileImageURL(token, username: profile.username) { _ in }

                UIBlockingProgressHUD.dismiss()
                self.switchToTabBarController()
            case .failure:
                UIBlockingProgressHUD.dismiss()
                self.alertAndSwitchToAuthViewController()
            }
        }
    }


}
