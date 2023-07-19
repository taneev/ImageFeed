//
//  ProfileDataSource.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 19.07.2023.
//

import Foundation

public protocol ProfileDataSourceProtocol: AnyObject {
    var avatarURL: String? { get }
    var profile: Profile? { get }
    var didChangeNotification: Notification.Name { get }
}

final class ProfileDataSource: ProfileDataSourceProtocol {
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared

    var avatarURL: String? {
        get { profileImageService.avatarURL }
    }
    var profile: Profile? {
        get { profileService.profile }
    }
    var didChangeNotification: Notification.Name {
        get {  ProfileImageService.DidChangeNotification }
    }
}
