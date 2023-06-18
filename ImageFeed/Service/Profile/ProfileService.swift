//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 11.06.2023.
//

import Foundation

final class ProfileService {

    static let shared = ProfileService()
    
    private let networkClient = NetworkClient()
    private let profileURLPath = "/me"
    private var task: URLSessionTask?
    private var currentToken: String?

    private(set) var profile: Profile?

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {

        assert(Thread.isMainThread)
        guard token != currentToken else {return}

        let request = networkClient.makeGetRequest(token, path: profileURLPath)
        self.task?.cancel()
        currentToken = token

        let task = networkClient.objectTask(for: request)
        {   [weak self] (result: Result<ProfileResult, Error>) in

            switch result {
            case .success(let profileResult):
                let profile = Profile(profileData: profileResult)
                DispatchQueue.main.async {[weak self] in
                    guard let self else {return}
                    self.profile = profile
                    completion(.success(profile))
                    self.task = nil
                }
            case .failure(let error):
                DispatchQueue.main.async {[weak self] in
                    guard let self else {return}

                    completion(.failure(error))
                    self.currentToken = nil
                    self.task = nil
                }
            }
        }
        self.task = task
        task.resume()
    }
}
