//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 11.06.2023.
//

import Foundation

final class ProfileService {

    private func makeProfileFetchRequest(_ token: String) -> URLRequest {
        var request = URLRequest(url: URL(string: "/me", relativeTo: DefaultBaseURL)!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {

        let request = makeProfileFetchRequest(token)

        let task = URLSession.shared.dataTask(with: request) {data, response, error in
            DispatchQueue.main.async {
                if let error {
                    return completion(.failure(NetworkError.transportError(error)))
                }
                else if let data,
                        let httpResponse = response as? HTTPURLResponse
                {
                    if 200..<300 ~= httpResponse.statusCode {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        do {
                            let profileData = try decoder.decode(ProfileResult.self, from: data)
                            return completion(.success(Profile(profileData: profileData)))
                        }
                        catch {
                            return completion(.failure(NetworkError.decodeError(error)))
                        }
                    }
                    else {
                        return completion(.failure(NetworkError.serverError(httpResponse.statusCode)))
                    }
                }
                else {
                    return completion(.failure(NetworkError.sessionError))
                }
            }
        }
        task.resume()
    }
}
