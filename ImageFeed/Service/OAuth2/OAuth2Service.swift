//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 04.06.2023.
//

import Foundation

final class OAuth2Service {

    private let tokenRequestURLString = "https://unsplash.com/oauth/token"
    private var task: URLSessionTask?
    private var lastCode: String?

    private func makeAuthRequest(code: String) -> URLRequest {
        var urlComponents = URLComponents(string: tokenRequestURLString)!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: AccessKey),
            URLQueryItem(name: "client_secret", value: SecretKey),
            URLQueryItem(name: "redirect_uri", value: RedirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]

        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"

        return request
    }

    func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {

        assert(Thread.isMainThread)
        if lastCode == code { return }
        task?.cancel()
        lastCode = code

        let request = makeAuthRequest(code: code)
        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            DispatchQueue.main.async {
                if let error {
                    completion(.failure(NetworkError.transportError(error)))
                    self.lastCode = nil
                }
                else if let data,
                        let httpResponse = response as? HTTPURLResponse {
                    if 200..<300 ~= httpResponse.statusCode {
                        let decoder = JSONDecoder()
                        do {
                            let responseObject = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                            completion(.success(responseObject.accessToken))
                        }
                        catch {
                            completion(.failure(NetworkError.decodeError(error)))
                        }
                    }
                    else {
                        completion(.failure(NetworkError.serverError(httpResponse.statusCode)))
                    }
                }
                else {
                    completion(.failure(NetworkError.sessionError))
                }
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }
}
