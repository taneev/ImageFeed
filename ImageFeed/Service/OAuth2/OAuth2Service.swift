//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 04.06.2023.
//

import Foundation

final class OAuth2Service {

    private let tokenRequestURLString = "https://unsplash.com/oauth/token"
    private let networkClient = NetworkClient()
    private var task: URLSessionTask?
    private var lastCode: String?
    private var authHelper: AuthHelper

    init(task: URLSessionTask? = nil, lastCode: String? = nil, authHelper: AuthHelper) {
        self.task = task
        self.lastCode = lastCode
        self.authHelper = authHelper
    }

    private func makeAuthRequest(code: String) -> URLRequest {
        var request = authHelper.makeAuthTokenRequest(withCode: code, urlString: tokenRequestURLString)
        request.httpMethod = "POST"

        return request
    }

    func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        assert(Thread.isMainThread)
        if lastCode == code { return }
        task?.cancel()
        lastCode = code

        let request = makeAuthRequest(code: code)
        let task = networkClient.objectTask(for: request){[weak self]
            (result: Result<OAuthTokenResponseBody, Error>) in

            switch result {
            case .success(let authRequestData):
                DispatchQueue.main.async {[weak self] in
                    guard let self else {return}
                    completion(.success(authRequestData.accessToken))
                    self.task = nil
                }
            case .failure(let error):
                DispatchQueue.main.async {[weak self] in
                    guard let self else {return}
                    completion(.failure(error))
                    self.lastCode = nil
                    self.task = nil
                }
            }
        }
        self.task = task
        task.resume()
    }
}
