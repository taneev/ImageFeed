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
        if let token = OAuth2TokenStorage().token {
            UIBlockingProgressHUD.show()
            profileFetch(token: token)
        }
        else {
            presentAuthViewController()
        }
    }

    private func createSplashLogoImageView() -> UIImageView {
        let logoImage = UIImage(named: "practicumLogo")
        let logoImageView = UIImageView(image: logoImage)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        return logoImageView
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }

        let tabBarViewController = UITabBarController()
        tabBarViewController.tabBar.barStyle = .default
        tabBarViewController.tabBar.isTranslucent = true
        tabBarViewController.tabBar.backgroundColor = .ypBlack
        tabBarViewController.tabBar.tintColor = .ypWhite

        let imagesListViewController = ImagesListViewController()
        imagesListViewController.presenter = ImagesListPresenter(viewController: imagesListViewController,
                                                                 dataSource: ImagesListService.shared)
        imagesListViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(systemName: "rectangle.stack.fill"),
            selectedImage: nil)

        let profileViewController = ProfileViewController()
        profileViewController.presenter = ProfilePresenter(viewController: profileViewController,
                                                           profileDataSource: ProfileDataSource())
        profileViewController.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil)

        tabBarViewController.viewControllers = [imagesListViewController, profileViewController]
        window.rootViewController = tabBarViewController
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewControllerDelegate(_ vc: AuthViewController, didGetToken token: String) {
        // сохраняем полученный токен
        OAuth2TokenStorage().token = token

        profileFetch(token: token)
        dismiss(animated: true)
    }

    private func presentAuthViewController() {
        let authViewController = AuthViewController()
        let navigationController = UINavigationController(rootViewController: authViewController)
        authViewController.delegate = self
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }

    private func alertAndSwitchToAuthViewController() {
        let alert = AlertModel(title: "Что-то пошло не так(",
                               message: "Не удалось войти в систему",
                               cancelButtonText: "Ок")
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
