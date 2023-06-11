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
            profileService.fetchProfile(token) {[weak self] result in
                switch result {
                case .success:
                    self?.switchToTabBarController()
                case .failure:
                    // TODO: разобраться что делать в таком случае
                    break
                }
            }

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

    func profileFetch(token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            switch result {
            case .success:
                self?.switchToTabBarController()
                UIBlockingProgressHUD.dismiss()
            case .failure:
                UIBlockingProgressHUD.dismiss()
            }
        }
    }


}
