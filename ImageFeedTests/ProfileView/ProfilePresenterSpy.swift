//
//  ProfilePresenterSpy.swift
//  ImageFeedTests
//
//  Created by Тимур Танеев on 19.07.2023.
//

import ImageFeed
import Foundation

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var viewDidLoadCalled: Bool = false

    var viewController: ImageFeed.ProfileViewControllerProtocol?

    var profileDataSource: ImageFeed.ProfileDataSourceProtocol

    init(viewController: ImageFeed.ProfileViewControllerProtocol?,
         profileDataSource: ImageFeed.ProfileDataSourceProtocol) {
        self.viewController = viewController
        self.profileDataSource = profileDataSource
    }

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func logout() {
        
    }
}

final class ProfileDataSourceDummy: ProfileDataSourceProtocol {
    var avatarURL: String? {
        get { "https://dummy.org" }
    }

    var profile: ImageFeed.Profile? {
        get {
            Profile(username: "username",
                      name: "first",
                      loginName: "loginName",
                      bio: "bio")
        }
    }

    var didChangeNotification: Notification.Name {
        get { Notification.Name("dummy") }
    }

}
