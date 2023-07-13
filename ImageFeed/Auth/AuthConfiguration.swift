//
//  Constants.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 03.06.2023.
//

import Foundation

let AccessKey = "GG_YMI5y_w-l-2rHSH9Kybym7uWVm8cxZfFjOA3ktF0"
let SecretKey = "yM_ey82X7CvKNiQ8nMaH98EGY0VmJmr4ahoU87Xq1_8"
let RedirectURI = "urn:ietf:wg:oauth:2.0:oob"
let AccessScope = "public+read_user+write_likes"
let DefaultBaseURL:URL = URL(string: "https://api.unsplash.com")!
let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String

    static var standard: AuthConfiguration {
            return AuthConfiguration(accessKey: AccessKey,
                                     secretKey: SecretKey,
                                     redirectURI: RedirectURI,
                                     accessScope: AccessScope,
                                     authURLString: UnsplashAuthorizeURLString,
                                     defaultBaseURL: DefaultBaseURL)
    }

    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
}
