//
//  Constants.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 03.06.2023.
//

import Foundation

private enum AuthConstants {
    static let accessKey = "GG_YMI5y_w-l-2rHSH9Kybym7uWVm8cxZfFjOA3ktF0"
    static let secretKey = "yM_ey82X7CvKNiQ8nMaH98EGY0VmJmr4ahoU87Xq1_8"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL:URL = URL(string: "https://api.unsplash.com")!
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String

    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: AuthConstants.accessKey,
                                 secretKey: AuthConstants.secretKey,
                                 redirectURI: AuthConstants.redirectURI,
                                 accessScope: AuthConstants.accessScope,
                                 authURLString: AuthConstants.unsplashAuthorizeURLString,
                                 defaultBaseURL: AuthConstants.defaultBaseURL)
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
