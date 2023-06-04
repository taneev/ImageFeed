//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 04.06.2023.
//

import UIKit

final class SplashViewController: UIViewController {

    private let authViewControllerSegueID = "AuthViewControllerSegue"
    private let authStorage = OAuth2TokenStorage()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let token = authStorage.token {
            switchToTabBarController()
        }
        else {
            performSegue(withIdentifier: authViewControllerSegueID, sender: self)
        }
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {fatalError("Invalid configuration")}

        let tabBarViewController = storyboard?.instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarViewController
    }

}
