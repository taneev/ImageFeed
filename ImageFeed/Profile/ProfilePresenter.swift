//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 19.07.2023.
//

import UIKit

public protocol ProfilePresenterProtocol {
    var viewController: ProfileViewControllerProtocol? { get set }
    var profileDataSource: ProfileDataSourceProtocol { get set }

    func viewDidLoad()
    func logout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    var profileDataSource: ProfileDataSourceProtocol
    weak var viewController: ProfileViewControllerProtocol?
    private var profileImageServiceObserver: NSObjectProtocol?

    init(viewController: ProfileViewControllerProtocol?, profileDataSource: ProfileDataSourceProtocol) {
        self.viewController = viewController
        self.profileDataSource = profileDataSource
    }

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

    func viewDidLoad() {
        if let avatarURL = profileDataSource.avatarURL {
            viewController?.updateAvatar(from: URL(string: avatarURL))
        }

        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: profileDataSource.didChangeNotification,
            object: nil,
            queue: .main)
        {   [weak self] _ in
            guard let self,
                let avatarURL = profileDataSource.avatarURL else { return }
            self.viewController?.updateAvatar(from: URL(string: avatarURL))
        }

        guard let profile = profileDataSource.profile else {return}
        viewController?.updateProfileDetails(profile: profile)
    }
}
