//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 11.06.2023.
//

import Foundation

final class ProfileService {

    private let networkClient = NetworkClient()
    private let profileURLPath = "/me"
    private var task: URLSessionTask?
    private var currentToken: String?

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {

        let request = networkClient.makeGetRequest(token, path: profileURLPath)

        if token == currentToken {return}
        self.task?.cancel()
        currentToken = token

        let task = networkClient.getDecodedObject(for: request, of: ProfileResult.self)
        {   [weak self] result in

            switch result {
            case .success(let profileResult):
                completion(.success(Profile(profileData: profileResult)))
            case .failure(let error):
                completion(.failure(error))
            }
            self?.currentToken = nil
            self?.task = nil
        }
        self.task = task
        task.resume()
    }
}
