//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Тимур Танеев on 11.06.2023.
//

import Foundation

final class ProfileImageService {

    static let shared = ProfileImageService()
    static let DidChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")

    private let networkClient = NetworkClient()
    private let profileImageURLPath = "/users"
    private var task: URLSessionTask?
    private var currentToken: String?
    private (set) var avatarURL: String?

    func fetchProfileImageURL(_ token: String, username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard token != currentToken else {return}

        task?.cancel()
        currentToken = token

        let request = networkClient.makeGetRequest(token,
                                                   path: profileImageURLPath+"/\(username)")
        let task = networkClient.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else {return}
            switch result {
            case .success(let userResult):
                if let smallImageURLString = userResult.profileImage?["small"] {
                    DispatchQueue.main.async { [weak self] in
                        guard let self else {return}

                        self.avatarURL = smallImageURLString
                        completion(.success(smallImageURLString))
                        self.task = nil
                    }
                    NotificationCenter.default
                        .post(
                            name: ProfileImageService.DidChangeNotification,
                            object: self,
                            userInfo: ["URL": smallImageURLString])
                }
                else {
                    DispatchQueue.main.async { [weak self] in
                        guard let self else {return}

                        completion(.failure(NetworkError.JSONError))
                        self.task = nil
                        self.currentToken = nil
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    guard let self else {return}

                    completion(.failure(error))
                    self.task = nil
                    self.currentToken = nil
                }
            }
        }
        self.task = task
        task.resume()
    }
}
