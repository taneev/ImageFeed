//
//  Profile.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 11.06.2023.
//

import Foundation

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String

    init(profileData: ProfileResult) {
        self.username = profileData.username
        self.name = "\(profileData.firstName) \(profileData.lastName)"
        self.loginName = "@\(profileData.username)"
        self.bio = profileData.bio ?? ""
    }
}
