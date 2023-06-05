//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 04.06.2023.
//

import Foundation

final class OAuth2TokenStorage {
    private let tokenKey = "UnsplashBearerToken"
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
        }
    }
}
