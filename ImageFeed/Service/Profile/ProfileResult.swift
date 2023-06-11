//
//  ProfileResult.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 11.06.2023.
//

import Foundation

struct ProfileResult: Decodable {
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?
}
