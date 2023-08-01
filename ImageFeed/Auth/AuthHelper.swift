//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 13.07.2023.
//

import Foundation

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest
    func code(from url: URL) -> String?
}

final class AuthHelper: AuthHelperProtocol {
    let configuration: AuthConfiguration

    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }
    
    func authRequest() -> URLRequest {
        let url = authURL()
        return URLRequest(url: url)
    }

    func authURL() -> URL {
        var urlComponents = URLComponents(string: configuration.authURLString)!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope)
        ]
        return urlComponents.url!
    }

    private func tokenRequestURL(withCode code: String, urlString: String) -> URL {
        var urlComponents = URLComponents(string: urlString)!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(name: "client_secret", value: configuration.secretKey),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        return urlComponents.url!
    }

    func makeAuthTokenRequest(withCode code: String, urlString: String) -> URLRequest {

        let url = tokenRequestURL(withCode: code, urlString: urlString)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }

    func code(from url: URL) -> String? {
        if  let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        }
        return nil
    }

    func defaultBaseURL() -> URL {
        return configuration.defaultBaseURL
    }
}
