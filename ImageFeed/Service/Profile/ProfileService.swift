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

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {

        let request = networkClient.makeGetRequest(token, path: profileURLPath)

        let task = networkClient.getDecodedObject(for: request, of: ProfileResult.self) { result in
            switch result {
            case .success(let data):
                completion(.success(Profile(profileData: data)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
