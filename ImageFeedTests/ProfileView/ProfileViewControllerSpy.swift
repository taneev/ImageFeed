//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Тимур Танеев on 19.07.2023.
//
import ImageFeed
import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {

    var updateAvatarCalled: Bool = false
    var updateProfileDetailsCalled: Bool = false

    var presenter: ProfilePresenterProtocol!

    func updateAvatar(from url: URL?) {
        updateAvatarCalled = true
    }

    func updateProfileDetails(profile: Profile) {
        updateProfileDetailsCalled = true
    }
}
