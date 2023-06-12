//
//  NetworkClient.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 11.06.2023.
//

import Foundation

final class NetworkClient {

    private let urlSession = URLSession.shared

    private func getData(for request: URLRequest,
              resultIn queue: DispatchQueue = DispatchQueue.main,
              completion: @escaping (Result<Data, Error>) -> Void ) -> URLSessionTask {

        let queueAsyncCompletion = {result in
            queue.async {
                completion(result)
            }
        }

        let task = urlSession.dataTask(with: request) {data, response, error in
            if let error {
                queueAsyncCompletion(.failure(NetworkError.transportError(error)))
            }
            else if let data,
                    let response,
                    let httpResponse = response as? HTTPURLResponse {
                if 200..<300 ~= httpResponse.statusCode {
                    queueAsyncCompletion(.success(data))
                }
                else {
                    queueAsyncCompletion(.failure(NetworkError.serverError(httpResponse.statusCode)))
                }
            }
            else {
                queueAsyncCompletion(.failure(NetworkError.sessionError))
            }
        }
        return task
    }

    func getDecodedObject<T>(for request: URLRequest,
                             of type: T.Type,
                             decodingStrategy strategy: JSONDecoder.KeyDecodingStrategy = .convertFromSnakeCase,
                             completion: @escaping (Result<T, Error>)-> Void)
    -> URLSessionTask where T:Decodable
    {

        let task = getData(for: request) { result in
            switch result {
            case .success(let data):
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = strategy
                do {
                    let decodedObject = try decoder.decode(type, from: data)
                    completion(.success(decodedObject))
                }
                catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }

    func makeGetRequest(_ token: String, path: String, relativeTo baseUrl: URL = DefaultBaseURL, requestParams: [String: String]? = nil) -> URLRequest {

        var urlComponents = URLComponents(string: baseUrl.absoluteString)!
        urlComponents.path = path
        if let queryItems = requestParams?.map({URLQueryItem(name: $0.key, value: $0.value)}) {
            urlComponents.queryItems = queryItems
        }

        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }


}
