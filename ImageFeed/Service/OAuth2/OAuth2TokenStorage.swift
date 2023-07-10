//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 10.07.2023.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let tokenKey = "UnsplashBearerToken"
    
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if newValue == nil {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
            else {
                KeychainWrapper.standard.set(newValue!, forKey: tokenKey)
            }
        }
    }
}
