//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 19.07.2023.
//

import UIKit

protocol ProfilePresenterProtocol {
    var  viewController: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func logout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private var profileImageServiceObserver: NSObjectProtocol?

    weak var viewController: ProfileViewControllerProtocol?

    init(viewController: ProfileViewControllerProtocol?) {
        self.viewController = viewController
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
        if let avatarURL = profileImageService.avatarURL {
            viewController?.updateAvatar(from: URL(string: avatarURL))
        }

        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.DidChangeNotification,
            object: nil,
            queue: .main)
        {   [weak self] _ in
            guard let self,
                let avatarURL = profileImageService.avatarURL else { return }
            self.viewController?.updateAvatar(from: URL(string: avatarURL))
        }

        guard let profile = profileService.profile else {return}
        viewController?.updateProfileDetails(profile: profile)
    }
}
