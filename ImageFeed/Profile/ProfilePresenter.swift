//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 19.07.2023.
//

import UIKit

protocol ProfilePresenterProtocol {
    func logout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    func logout() {
        OAuth2TokenStorage().token = nil
        OAuth2CookieStorage.clean()

        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        let splashViewController = SplashViewController()
        window.rootViewController = splashViewController
    }
}
