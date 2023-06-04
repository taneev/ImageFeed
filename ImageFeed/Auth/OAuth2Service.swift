//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 04.06.2023.
//

import Foundation

enum NetworkError: Error {
    case serverError(Int)
    case transportError(Error)
    case decodeError(Error)
    case sessionError
}

final class OAuth2Service {
    func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {

        let mainQueueCompletion: ((Result<String, Error>) -> Void) = {result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token")!
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: AccessKey),
            URLQueryItem(name: "client_secret", value: SecretKey),
            URLQueryItem(name: "redirect_uri", value: RedirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]

        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            if let error {
                completion(.failure(NetworkError.transportError(error)))
            }
            else if let data,
                    let httpResponse = response as? HTTPURLResponse {
                if 200..<300 ~= httpResponse.statusCode {
                    let decoder = JSONDecoder()
                    do {
                        let responseObject = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                        mainQueueCompletion(.success(responseObject.accessToken))
                    }
                    catch {
                        mainQueueCompletion(.failure(NetworkError.decodeError(error)))
                    }
                }
                else {
                    mainQueueCompletion(.failure(NetworkError.serverError(httpResponse.statusCode)))
                }
            }
            else {
                mainQueueCompletion(.failure(NetworkError.sessionError))
            }
        }
    }
}
