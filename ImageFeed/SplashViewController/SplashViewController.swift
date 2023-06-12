//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 04.06.2023.
//

import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {

    private let authViewControllerSegueID = "AuthViewControllerSegue"
    private let authStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let token = authStorage.token {
            UIBlockingProgressHUD.show()
            profileFetch(token: token)
        }
        else {
            performSegue(withIdentifier: authViewControllerSegueID, sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == authViewControllerSegueID {
            guard let navigationController = segue.destination as? UINavigationController,
                  let authViewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Segue \(authViewControllerSegueID) prepare error") }
            authViewController.delegate = self
        }
        else {
            super.prepare(for: segue, sender: sender)
        }
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {fatalError("Invalid configuration")}

        let tabBarViewController = storyboard?.instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarViewController
    }

}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewControllerDelegate(_ vc: AuthViewController, didGetToken token: String) {
        self.authStorage.token = token // сохраняем полученный токен
        profileFetch(token: token)
        dismiss(animated: true)
    }

    private func alertAndSwitchToAuthViewController() {
        let alert = AlertModel(title: "Что-то пошло не так(",
                               message: "Не удалось войти в систему",
                               buttonText: "Ок")
        let alertPresenter = AlertPresenter(controller: self)
        alertPresenter.showAlert(alert: alert) {[weak self] _ in
            guard let self else {return}
            performSegue(withIdentifier: self.authViewControllerSegueID, sender: self)
        }
    }

    func profileFetch(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self else {return}

            switch result {
            case .success(let profile):
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
