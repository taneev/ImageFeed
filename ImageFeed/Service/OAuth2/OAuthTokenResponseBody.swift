//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 04.06.2023.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Date
}
